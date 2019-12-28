# -*- coding: utf-8 -*-
from enum import Enum


class Token(object):
    class Type(Enum):
        CODE = 0
        PRAGMA = 1
        IF = 2
        ELSE = 3
        ELIF = 4
        ENDIF = 5
        EOF = 6

    def __init__(self, type_: int, value: str):
        self.type_ = type_
        self.value = value

    def __repr__(self) -> str:
        return "<{}, {}>".format(repr(self.value), self.type_)

    @staticmethod
    def directive_from_str(str_: str):
        if str_ == "pragma":
            return Token.Type.PRAGMA
        if str_ == "if":
            return Token.Type.IF
        if str_ == "else":
            return Token.Type.ELSE
        if str_ == "elif":
            return Token.Type.ELIF
        if str_ == "endif":
            return Token.Type.ENDIF
        return None


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
