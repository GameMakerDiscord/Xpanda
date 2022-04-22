# -*- coding: utf-8 -*-
import re

def minify(code: str) -> str:
    # Mark end of directives
    code = re.sub(r"([^\S\n]*#[^\n]+)", "%NEWLINE%\\1%NEWLINE%", code)

    # Remove comments
    code = re.sub(r"//[^\n]*", "", code)
    code = re.sub(r"/\*(?:\*[^/]|[^*])*\*/", "", code)

    # Remove newlines
    code = re.sub(r"\n+", " ", code)

    # Collapse whitespace
    code = re.sub(r"\s{2,}", " ", code)
    for c in r"+-*%/!~|&=$<>[]{}().:,;?":
        code = re.sub(f"\\s*\{c}\\s*", c, code)

    # Add in newlines for directives
    code = code.replace("%NEWLINE%", "\n")
    code = re.sub(r"\n\s+", "\n", code)

    return code.strip()
