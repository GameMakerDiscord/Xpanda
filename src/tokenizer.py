# -*- coding: utf-8 -*-
import os
import re

from enum import Enum, auto

from src.legacy import P_INCLUDE_START

class Token(object):
    class Type(Enum):
        CODE = auto()
        DIRECTIVE = auto()
        DEFINE = auto()
        UNDEF = auto()
        PRAGMA = auto()
        IF = auto()
        IFDEF = auto()
        IFNDEF = auto()
        ELSE = auto()
        ELIF = auto()
        ENDIF = auto()
        EOF = auto()
        # Control nodes in token tree:
        ROOT = auto()
        BRANCH = auto()

    def __init__(self, type_: int, value: str):
        self.type_ = type_
        self.value = value
        self.root = self
        self.parent = None
        self.prev = None
        self.next = None
        self.children = []
        self.evaluated = None

    def __repr__(self) -> str:
        return "<{}, {}>".format(repr(self.value), self.type_)

    @staticmethod
    def directive_from_str(str_: str):
        if str_ == "define":
            return Token.Type.DEFINE
        if str_ == "undef":
            return Token.Type.UNDEF
        if str_ == "pragma":
            return Token.Type.PRAGMA
        if str_ == "if":
            return Token.Type.IF
        if str_ == "ifdef":
            return Token.Type.IFDEF
        if str_ == "ifndef":
            return Token.Type.IFNDEF
        if str_ == "else":
            return Token.Type.ELSE
        if str_ == "elif":
            return Token.Type.ELIF
        if str_ == "endif":
            return Token.Type.ENDIF
        return Token.Type.DIRECTIVE

    def add(self, child):
        child.root = self.root
        child.parent = self
        if len(self.children) > 0:
            last = self.children[-1]
            last.next = child
            child.prev = last
        self.children.append(child)

def get_first_word(line: str) -> str:
    return line.split(None, 1)[0]


def tokenize(file: str) -> list:
    tokens = []

    token_type = Token.Type.CODE
    token_str = ""

    def append_token():
        nonlocal token_type, token_str

        if token_str != "":
            tokens.append(Token(token_type, token_str))
            token_str = ""

        token_type = Token.Type.CODE

    with open(file, "r") as f:
        while True:
            line = f.readline()
            if not line:
                break

            stripped = line.lstrip()

            try:
                first_char = stripped[0]
            except IndexError:
                first_char = ""

            if first_char == "#":
                append_token()

                first_word = get_first_word(stripped[1:])
                token_type = Token.directive_from_str(first_word)

                if token_type is not None:
                    tokens.append(Token(token_type, line))
                    continue

            if token_type != Token.Type.CODE:
                append_token()
            token_type = Token.Type.CODE
            token_str += line

        append_token()
        tokens.append(Token(Token.Type.EOF, ""))

    return tokens

def make_tree(tokens: list) -> Token:
    root = Token(Token.Type.ROOT, "")

    i = 0
    current = root

    while i < len(tokens):
        token = tokens[i]
        i += 1

        if token.type_ == Token.Type.CODE:
            current.add(token)
            continue

        if token.type_ == Token.Type.DIRECTIVE:
            current.add(token)
            continue

        if token.type_ == Token.Type.DEFINE:
            current.add(token)
            continue

        if token.type_ == Token.Type.UNDEF:
            current.add(token)
            continue

        if token.type_ == Token.Type.PRAGMA:
            current.add(token)
            continue

        if token.type_ == Token.Type.IF:
            branch = Token(Token.Type.BRANCH, "")
            current.add(branch)
            branch.add(token)
            current = token
            continue

        if token.type_ == Token.Type.IFDEF:
            branch = Token(Token.Type.BRANCH, "")
            current.add(branch)
            branch.add(token)
            current = token
            continue

        if token.type_ == Token.Type.IFNDEF:
            branch = Token(Token.Type.BRANCH, "")
            current.add(branch)
            branch.add(token)
            current = token
            continue

        if token.type_ == Token.Type.ELSE:
            current.parent.add(token)
            current = token
            continue

        if token.type_ == Token.Type.ELIF:
            current.parent.add(token)
            current = token
            continue

        if token.type_ == Token.Type.ENDIF:
            current = current.parent
            current.add(token)
            current = current.parent
            continue

        if token.type_ == Token.Type.EOF:
            root.add(token)
            break

    return root

def print_tree(token: Token, indent = 0):
    print(" " * (indent * 4), token)
    for c in token.children:
        print_tree(c, indent + 1)

def process_tree(token: Token, env: dict, xshaders: str, xshaders_default: str) -> str:
    code = ""
    includes = []

    def _replace_vars(t: Token, python: bool = False) -> bool:
        val_orig = t.value

        if python:
            f = re.findall(r"defined\(([^)]+)\)", t.value)
            for e in f:
                if e.startswith("X_"):
                    t.value = t.value.replace(f"defined({e})", "True" if e in env else "False")

        for k, v in env.items():
            if python:
                _str = " {} ".format(str(v))
            else:
                if isinstance(v, bool):
                    _str = "true" if v else "false"
                else:
                    _str = str(v)
            t.value = re.sub(r"\b{}\b".format(k), _str, t.value)

        # FIXME: OMFG
        if python:
            t.value = t.value.replace("!=", "__NEQ__")
            replace = {
                "&&": " and ",
                "||": " or ",
                "!": " not ",
                "true": "True",
                "false": "False",
            }
            for k, v in replace.items():
                t.value = t.value.replace(k, v)
            t.value = t.value.replace("__NEQ__", " != ")

            # if t.value != val_orig:
            #     print("Python:", t.value)

        return t.value != val_orig

    def _eval_token(token: Token):
        value_backup = token.value
        token.evaluated = None

        if token.type_ == Token.Type.IFDEF:
            name = token.value.lstrip()[1:].split()[1]
            if name.startswith("X_"):
                token.evaluated = name in env
        elif token.type_ == Token.Type.IFNDEF:
            name = token.value.lstrip()[1:].split()[1]
            if name.startswith("X_"):
                token.evaluated = name not in env
        elif token.type_ in [Token.Type.ELSE, Token.Type.ENDIF]:
            token.evaluated = True
        elif token.type_ in [Token.Type.IF, Token.Type.ELIF]:
            try:
                _replace_vars(token, python=True)
                line = " ".join(token.value.lstrip()[1:].split()[1:])
                token.evaluated = eval(line)
            except:
                token.value = value_backup
                _replace_vars(token)
                token.evaluated = None

        return token.evaluated

    def _process(token):
        nonlocal code
        nonlocal includes
        nonlocal env

        if token.type_ == Token.Type.CODE:
            code += token.value
            return

        if token.type_ == Token.Type.DIRECTIVE:
            code += token.value
            return

        if token.type_ == Token.Type.DEFINE:
            code += token.value
            m = re.match(r"\s*#\s*define\s*(?P<name>\w+)\s*(?P<value>[^\n]+)?", token.value)
            if m:
                name = m.group("name")
                if name.startswith("X_"):
                    value = m.group("value")
                    value = "" if value is None else value
                    env[name] = value
            return

        if token.type_ == Token.Type.UNDEF:
            code += token.value
            m = re.match(r"\s*#\s*undef\s*(?P<name>\w+)", token.value)
            if m:
                name = m.group("name")
                if name.startswith("X_"):
                    del env[name]
            return

        if token.type_ == Token.Type.PRAGMA:
            indent = token.value.index("#")

            m = re.match(r"\s*" + P_INCLUDE_START, token.value)
            if m:
                include_fname = m.group("fname").split("/")
                include_fname = os.path.join(*include_fname)

                if include_fname in includes:
                    return []

                code += token.value

                includes.append(include_fname)

                _fpath = os.path.join(xshaders, include_fname)
                if not os.path.exists(_fpath):
                    _fpath = os.path.join(xshaders_default, include_fname)

                tokens_new = tokenize(_fpath)[:-1]
                tokens_new_tree = make_tree(tokens_new)
                token.add(tokens_new_tree)

                end_token = Token(Token.Type.CODE, (" " * indent) + f'// include("{include_fname}")\n')
                token.add(end_token)

                for c in token.children:
                    _process(c)
            return

        if token.type_ == Token.Type.IF:
            for c in token.children:
                _process(c)
            return

        if token.type_ == Token.Type.IFDEF:
            for c in token.children:
                _process(c)
            return

        if token.type_ == Token.Type.IFNDEF:
            for c in token.children:
                _process(c)
            return

        if token.type_ == Token.Type.ELSE:
            for c in token.children:
                _process(c)
            return

        if token.type_ == Token.Type.ELIF:
            for c in token.children:
                _process(c)
            return

        if token.type_ == Token.Type.ENDIF:
            return

        if token.type_ == Token.Type.EOF:
            return

        if token.type_ == Token.Type.ROOT:
            for c in token.children:
                _process(c)
            return

        if token.type_ == Token.Type.BRANCH:
            # Check if all of the branches can be evaluated. If not, then keep
            # all of them.
            keep_all = False
            for c in token.children:
                if _eval_token(c) is None:
                    keep_all = True
            if keep_all:
                for c in token.children:
                    code += c.value
                    _process(c)
                return
        
            # Otherwise keep the first branch evaluated to true.
            for c in token.children:
                if c.evaluated == True:
                    _process(c)
                    return
            return

    _process(token)

    return code
