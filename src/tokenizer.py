# -*- coding: utf-8 -*-
from enum import Enum, auto


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
