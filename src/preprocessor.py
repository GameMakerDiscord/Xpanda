# -*- coding: utf-8 -*-
import re

from .minifier import minify
from .tokenizer import Token


class Preprocessor(object):
    def __init__(self, tokens: list, env: dict = {}, minify: bool = False):
        self.index = 0
        self.tokens = tokens
        self.env = env
        self.minify = minify

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

    def _process_pragma(self):
        token = self._peek()
        if not token or token.type_ != Token.Type.PRAGMA:
            return None
        self._next()
        self._replace_vars(token)
        if self.minify:
            token.value = minify(token.value) + "\n"
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
                self._process()

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
                            self._process()
                    else:
                        self._process()

                elif _next and _next.type_ == Token.Type.ELSE:
                    self._next()
                    if not res:
                        processed += self._process()
                    else:
                        self._process()
                    self._consume(Token.Type.ENDIF)
                    break

                else:
                    self._consume(Token.Type.ENDIF,
                                  Token.Type.ELSE,
                                  Token.Type.ELIF)
                    break

        else:
            processed.append(token)
            processed += self._process()

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

    def _process(self, toplevel=False) -> list:
        processed = []

        while True:
            _directive = self._process_directive()
            if _directive:
                processed += _directive
                continue

            _pragma = self._process_pragma()
            if _pragma:
                processed += _pragma
                continue

            _if = self._process_if()
            if _if:
                processed += _if
                continue

            _code = self._process_code()
            if _code:
                processed += _code
                continue

            break

        if toplevel:
            self._consume(Token.Type.EOF)

        return processed

    def process(self) -> str:
        processed = self._process(toplevel=True)
        return "".join([t.value for t in processed])
