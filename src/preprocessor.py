# -*- coding: utf-8 -*-
import os
import re

from .tokenizer import Token, make_tree, tokenize

P_INCLUDE_START = r"#\s*pragma\s+include\s*\(\s*\"(?P<fname>[\w./]+)\"(\s*,\s*\"(?P<lang>\w+)\")?\s*\).*"

P_INCLUDE_END = r"//\s*include\s*\(\s*\"(?P=fname)\"\s*\)"

def clear(file):
    """ Clears old expanded code from the file, leaving only the pragma include
    lines. """
    data = ""
    cleared = False

    pattern = r"(?P<pstart>" + P_INCLUDE_START + r")" + \
        r"[\s\S]*" + P_INCLUDE_END
    regex = re.compile(pattern)

    with open(file, "r") as f:
        data = regex.sub(lambda m: m.group().replace(
            m.group(), m.group("pstart")), f.read())
        cleared = True

    if cleared:
        with open(file, "w") as f:
            f.write(data)

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


def handle_compatibility(string, lang):
    if lang == "glsl":
        names = {
            "Texture2D": "sampler2D",
            "Vec2": "vec2",
            "Vec3": "vec3",
            "Vec4": "vec4",
            "Mat2": "mat2",
            "Mat3": "mat3",
            "Mat4": "mat4",
            "DDX": "dFdx",
            "DDY": "dFdy",
            "Frac": "fract",
            "Lerp": "mix",
            "Rsqrt": "inversesqrt",
            "Mod": "mod",
        }
    elif lang.startswith("hlsl"):
        names = {
            "Vec2": "float2",
            "Vec3": "float3",
            "Vec4": "float4",
            "Mat2": "float2x2",
            "Mat3": "float3x3",
            "Mat4": "float4x4",
            "DDX": "ddx",
            "DDY": "ddy",
            "Frac": "frac",
            "Lerp": "lerp",
            "Rsqrt": "rsqrt",
            "Mod": "fmod",
        }
        if lang == "hlsl9":
            names["Texture2D"] = "sampler2D"
        else:
            names["Texture2D"] = "Texture2D"

    for k in names:
        string = re.sub(r"\b" + k + r"\b", names[k], string)

    # Sample
    regex = re.compile(r"\bSample\s*\(\s*(\w+)")
    if lang == "glsl":
        string = regex.sub(lambda m: m.group().replace(
            "Sample", "texture2D"), string)
    elif lang == "hlsl9":
        string = regex.sub(lambda m: m.group().replace(
            "Sample", "tex2D"), string)
    elif lang == "hlsl11":
        string = regex.sub(lambda m: m.group().replace(
            m.group(), m.group(1) + ".Sample(gm_BaseTexture"), string)

    return string
