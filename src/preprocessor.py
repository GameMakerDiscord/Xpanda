# -*- coding: utf-8 -*-
import os
import re

from .minifier import minify
from .tokenizer import Token, tokenize
from .legacy import P_INCLUDE_START

class Preprocessor(object):
    def __init__(self, tokens: list, xshaders: str, xshaders_default: str, lang: str, env: dict = {}, minify: bool = False):
        self.index = 0
        self.tokens = tokens
        self.xshaders = xshaders
        self.xshaders_default = xshaders_default
        self.lang = lang
        self.env = env
        self.minify = minify
        self.includes = []

    def _next(self):
        self.index += 1

    def _peek(self):
        if self.index < len(self.tokens):
            token = self.tokens[self.index]
            return token
        return None

    def _consume(self, *args) -> Token:
        token = self._peek()
        if not token or token.type_ not in args:
            raise Exception("Syntax error: {} expected, found {}!".format(
                str(args), token.type_))
        self._next()
        return token

    def _replace_vars(self, t: Token, python: bool = False) -> bool:
        val_orig = t.value

        if python:
            f = re.findall(r"defined\(([^)]+)\)", t.value)
            for e in f:
                if e.startswith("X_"):
                    t.value = t.value.replace(f"defined({e})", "True" if e in self.env else "False")

        for k, v in self.env.items():
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

    def _process_directive(self):
        token = self._peek()
        if not token or token.type_ != Token.Type.DIRECTIVE:
            return None
        self._next()
        self._replace_vars(token)
        if self.minify:
            token.value = minify(token.value) + "\n"
        return [token]

    def _process_pragma(self, expand=True):
        token = self._peek()
        if not token or token.type_ != Token.Type.PRAGMA:
            return None
        self._next()
        self._replace_vars(token)
        if self.minify:
            token.value = minify(token.value) + "\n"

        m = re.match(r"\s*" + P_INCLUDE_START, token.value)
        if m:
            if not expand:
                return []

            include_fname = m.group("fname").split("/")
            include_fname = os.path.join(*include_fname)
            include_lang = m.group("lang")

            if include_fname in self.includes:
                return []

            self.includes.append(include_fname)

            _fpath = os.path.join(self.xshaders, include_fname)
            if not os.path.exists(_fpath):
                _fpath = os.path.join(self.xshaders_default, include_fname)

            _tokens_new = tokenize(_fpath)[:-1] + \
                [Token(Token.Type.CODE, f'// include("{include_fname}")\n')]

            # print(_tokens_new)

            self.tokens = self.tokens[:self.index] + \
                _tokens_new + \
                self.tokens[self.index:]

        return [token]

    def _process_if(self):
        token = self._peek()
        if not token or token.type_ != Token.Type.IF:
            return None
        self._next()

        processed = []
        value_backup = token.value

        try:
            self._replace_vars(token, python=True)
            line = " ".join(token.value.lstrip()[1:].split()[1:])
            res = eval(line)
            evaluated = True
        except:
            token.value = value_backup
            self._replace_vars(token)
            evaluated = False

        if self.minify:
            token.value = minify(token.value) + "\n"

        if evaluated:
            if res:
                processed += self._process()
            else:
                self._process(expand=False)

            # FIXME: WTF is this shit
            while True:
                _next = self._peek()

                if _next and _next.type_ == Token.Type.ENDIF:
                    self._next()
                    break

                elif _next and _next.type_ == Token.Type.ELIF:
                    self._next()

                    if not res:
                        self._replace_vars(_next, python=True)
                        line = " ".join(_next.value.lstrip()[1:].split()[1:])

                        res = eval(line)

                        if res:
                            processed += self._process()
                        else:
                            self._process(expand=False)
                    else:
                        self._process(expand=False)

                elif _next and _next.type_ == Token.Type.ELSE:
                    self._next()
                    if not res:
                        processed += self._process()
                    else:
                        self._process(expand=False)
                    self._consume(Token.Type.ENDIF)
                    break

                else:
                    self._consume(Token.Type.ENDIF,
                                  Token.Type.ELSE,
                                  Token.Type.ELIF)
                    break

        else:
            processed.append(token)
            processed += self._process(expand=False)

            while True:
                _next = self._peek()

                if _next and _next.type_ == Token.Type.ENDIF:
                    self._replace_vars(_next)
                    if self.minify:
                        _next.value = minify(_next.value) + "\n"
                    self._next()
                    processed.append(_next)
                    break

                elif _next and _next.type_ == Token.Type.ELIF:
                    self._replace_vars(_next)
                    self._next()
                    if self.minify:
                        _next.value = minify(_next.value) + "\n"
                    processed.append(_next)
                    processed += self._process()

                elif _next and _next.type_ == Token.Type.ELSE:
                    self._replace_vars(_next)
                    self._next()
                    if self.minify:
                        _next.value = minify(_next.value) + "\n"
                    processed.append(_next)
                    processed += self._process()
                    _next = self._consume(Token.Type.ENDIF)
                    if self.minify:
                        _next.value = minify(_next.value) + "\n"
                    processed.append(_next)
                    break

                else:
                    _next = self._consume(Token.Type.ENDIF,
                                          Token.Type.ELSE,
                                          Token.Type.ELIF)
                    if self.minify:
                        _next.value = minify(_next.value) + "\n"
                    processed.append(_next)
                    break

        return processed

    def _process_ifdef(self):
        token = self._peek()
        if not token or token.type_ != Token.Type.IFDEF:
            return None
        self._next()
        self._replace_vars(token)
        if self.minify:
            token.value = minify(token.value) + "\n"

        processed = [token]

        while True:
            _next = self._peek()
            if _next.type_ == Token.Type.ENDIF:
                processed.append(self._consume(Token.Type.ENDIF))
                break
            elif _next.type_ == Token.Type.ELSE:
                processed.append(self._consume(Token.Type.ELSE))
            else:
                processed += self._process()

        return processed

    def _process_ifndef(self):
        token = self._peek()
        if not token or token.type_ != Token.Type.IFNDEF:
            return None
        self._next()
        self._replace_vars(token)
        if self.minify:
            token.value = minify(token.value) + "\n"

        processed = [token]

        while True:
            _next = self._peek()
            if _next.type_ == Token.Type.ENDIF:
                processed.append(self._consume(Token.Type.ENDIF))
                break
            elif _next.type_ == Token.Type.ELSE:
                processed.append(self._consume(Token.Type.ELSE))
            else:
                processed += self._process()

        return processed

    def _process_code(self):
        token = self._peek()
        if not token or token.type_ != Token.Type.CODE:
            return None
        self._next()
        self._replace_vars(token)
        if self.minify:
            token.value = minify(token.value)
            if token.value:
                token.value += "\n"
        return [token]

    def _process(self, toplevel=False, expand=True) -> list:
        processed = []

        while True:
            _directive = self._process_directive()
            if _directive is not None:
                processed += _directive
                continue

            _pragma = self._process_pragma(expand)
            if _pragma is not None:
                processed += _pragma
                continue

            _if = self._process_if()
            if _if is not None:
                processed += _if
                continue

            _ifdef = self._process_ifdef()
            if _ifdef is not None:
                processed += _ifdef
                continue

            _ifndef = self._process_ifndef()
            if _ifndef is not None:
                processed += _ifndef
                continue

            _code = self._process_code()
            if _code is not None:
                processed += _code
                continue

            break

        if toplevel:
            self._consume(Token.Type.EOF)

        return processed

    def process(self) -> str:
        processed = self._process(toplevel=True)
        return "".join([t.value for t in processed])
