# -*- coding: utf-8 -*-
import os
from enum import Enum


def minify(line: str) -> str:
    result = ""
    is_string = ""  # ' or " based on string delimiter
    is_comment = ""  # / for single-line, * for multi-line
    char_last = ""

    for char in line:
        if not is_string:
            if char == "/" and char_last == "/" and not is_comment:
                # Start of single-line comment
                is_comment = "/"
                result = result[:-1]
            elif char == "*" and char_last == "/" and not is_comment:
                # Start of multi-line comment
                is_comment = "*"
                result = result[:-1]

        if is_comment:
            # Remove comments
            pass
        elif is_string:
            # Keep strings untouched
            result += char
        else:
            # Remove multiple consecutive whitespace characters from everywhere else
            if char.isspace():
                if not char_last.isspace():
                    char = " "
                    result += char
            else:
                result += char

        if is_comment:
            if is_comment == "/" and char == "\n":
                # End of single-line comment
                is_comment = ""
            elif is_comment == "*" and char == "/" and char_last == "*":
                # End of multi-line comment
                is_comment = ""
        elif char_last != "\\" and char in ["'", '"']:
            # Start and end of strings
            if not is_string:
                is_string = char
            elif is_string == char:
                is_string = ""

        char_last = char

    return result.strip()
