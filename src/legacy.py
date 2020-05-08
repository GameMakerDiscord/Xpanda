# -*- coding: utf-8 -*-
import os
import re

from .common import *

P_INCLUDE_START = r"#\s*pragma\s+include\s*\(\s*\"(?P<fname>[\w./]+)\"(\s*,\s*\"(?P<lang>\w+)\")?\s*\).*"

P_INCLUDE_END = r"\/\/ include\(\"(?P=fname)\"\)"


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


def expand(file, xshaders, xshaders_default, out, lang):
    """ Recursively expands pragma includes in the file. """
    data = ""
    includes = []
    level = 0

    def do_expand(file):
        nonlocal data
        nonlocal includes
        nonlocal level
        nonlocal lang
        print(" " * 2 * level + "Expanding " + file)

        with open(file, "r") as f:
            lines = f.readlines()
            for l in lines:
                m = re.match(r"\s*" + P_INCLUDE_START, l)
                if m:
                    include_fname = m.group("fname").split("/")
                    include_fname = os.path.join(*include_fname)
                    include_lang = m.group("lang")
                    if include_lang:
                        if include_lang not in LANGS:
                            raise ValueError(
                                "Unknown language {}!".format(include_lang))
                        if level == 0:
                            lang = include_lang
                        else:
                            if include_lang != lang:
                                raise ValueError(
                                    "Cannot include {} into {} shader!".format(include_lang, lang))
                    if level == 0:
                        data += l
                    if not include_fname in includes:
                        includes.append(include_fname)
                        level += 1

                        _fpath = os.path.join(xshaders, include_fname)
                        if not os.path.exists(_fpath):
                            _fpath = os.path.join(xshaders_default, include_fname)

                        do_expand(_fpath)

                        while data[-1].rstrip() == "":
                            data = data[:-1]

                        data += "\n"
                        level -= 1
                        if level == 0:
                            data += "// include(\"{}\")\n".format(m.group("fname"))
                else:
                    if level != 0:
                        data += handle_compatibility(l, lang)
                    else:
                        data += l

    do_expand(file)

    print("Expanded as " + lang)

    try:
        os.mkdir(os.path.dirname(out))
    except:
        pass

    with open(out, "w") as f:
        f.write(data)

    return lang
