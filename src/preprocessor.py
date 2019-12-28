# -*- coding: utf-8 -*-
import re

from .tokenizer import Token


class Preprocessor(object):
    def __init__(self, tokens: list, env: dict = {}):
        self.index = 0
        self.tokens = tokens
        self.env = env

    def _next(self):
        self.index += 1

    def _peek(self):
        if self.index < len(self.tokens):
            token = self.tokens[self.index]
            return token
        return None

    def _consume(self, type_) -> Token:
        token = self._peek()
        if not token or token.type_ != type_:
            raise Exception("Syntax error: {} expected, found {}!".format(type_, token.type_))
        self._next()
        return token

    def _replace_vars(self, t: Token) -> bool:
        val_orig = t.value

        for k, v in self.env.items():
            t.value = re.sub(r"\b{}\b".format(k), str(v), t.value)

        return t.value != val_orig

    def _process_pragma(self):
        token = self._peek()
        if not token or token.type_ != Token.Type.PRAGMA:
            return None
        self._next()
        self._replace_vars(token)
        return [token]

    def _process_if(self):
        token = self._peek()
        if not token or token.type_ != Token.Type.IF:
            return None
        self._next()
        replaced = self._replace_vars(token)
        evaluated = False

        processed = []
        line = " ".join(token.value.lstrip()[1:].split()[1:])

        try:
            res = eval(line)
            evaluated = True
        except:
            if replaced:
                raise

        if evaluated:
            if res:
                processed += self._process()
            else:
                self._process()
            self._consume(Token.Type.ENDIF)
        else:
            processed.append(token)
            processed += self._process()
            processed.append(self._consume(Token.Type.ENDIF))

        return processed

    def _process_code(self):
        token = self._peek()
        if not token or token.type_ != Token.Type.CODE:
            return None
        self._next()
        self._replace_vars(token)
        return [token]

    def _process(self, toplevel=False) -> list:
        processed = []

        while True:
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
