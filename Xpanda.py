#!/usr/bin/env python
# -*- coding: utf-8 -*-
import argparse
import os
import re

PATH_XSHADERS_DEFAULT = "./Xshaders/"
LANG_DEFAULT = "glsl"

P_INCLUDE_START = r"#\s*pragma\s+include\s*\(\s*\"(?P<fname>[\w.]+)\"(\s*,\s*\"(?P<lang>\w+)\")?\s*\).*"
P_INCLUDE_END = r"\/\/ include\(\"(?P=fname)\"\)"


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
            "Frac": "fract",
            "Lerp": "mix",
            "DDX": "dFdx",
            "DDY": "dFdy"
        }
    elif lang == "hlsl":
        names = {
            "Texture2D": "Texture2D",
            "Vec2": "float2",
            "Vec3": "float3",
            "Vec4": "float4",
            "Mat2": "float2x2",
            "Mat3": "float3x3",
            "Mat4": "float4x4",
            "Frac": "frac",
            "Lerp": "lerp",
            "DDX": "ddx",
            "DDY": "ddy"
        }
    else:
        raise ValueError("Invalid language {}".format(lang))

    for k in names:
        string = re.sub(r"\b" + k + r"\b", names[k], string)

    regex = re.compile(r"\bSample\s*\(\s*(\w+)")
    if lang == "hlsl":
        string = regex.sub(lambda m: m.group().replace(
            m.group(), m.group(1) + ".Sample(gm_BaseTexture"), string)
    else:
        string = regex.sub(lambda m: m.group().replace(
            "Sample", "texture2D"), string)

    return string


def expand(file, xshaders, lang):
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
                    include_fname = m.group("fname")
                    include_lang = m.group("lang")
                    if include_lang:
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
                        do_expand(os.path.join(xshaders, include_fname))
                        data += "\n"
                        level -= 1
                        if level == 0:
                            data += "// include(\"{}\")\n".format(include_fname)
                else:
                    data += handle_compatibility(l, lang)

    do_expand(file)

    if lang == "glsl":
        pattern = r"#if Xhlsl[\s\S]*#endif // Xhlsl\n?"
        regex = re.compile(pattern)
        data = regex.sub(lambda m: "", data)
        data = data.replace("#if Xglsl\n", "")
        data = data.replace("\n#endif // Xglsl", "")
    elif lang == "hlsl":
        pattern = r"#if Xglsl[\s\S]*#endif // Xglsl\n?"
        regex = re.compile(pattern)
        data = regex.sub(lambda m: "", data)
        data = data.replace("#if Xhlsl\n", "")
        data = data.replace("\n#endif // Xhlsl", "")

    print("Expanded as " + lang)
    print("-" * 80)

    with open(file, "w") as f:
        f.write(data)


if __name__ == "__main__":
    PARSER = argparse.ArgumentParser(
        description="Include code from external files into your shaders.")
    PARSER.add_argument(
        "path", metavar="PATH", type=str, help="path to the folder containing your shaders")
    PARSER.add_argument(
        "--x", metavar="EXTERNAL", type=str, default=PATH_XSHADERS_DEFAULT, help="path to the folder containing the external files (default is {})".format(PATH_XSHADERS_DEFAULT))
    PARSER.add_argument(
        "--l", metavar="LANG", type=str, default=LANG_DEFAULT, help="fallback shader language when not specified by include; can be either glsl or hlsl (default is {})".format(LANG_DEFAULT))

    ARGS = PARSER.parse_args()
    PATH = os.path.realpath(ARGS.path)
    XPATH = os.path.realpath(ARGS.x)

    for dirpath, dirnames, filenames in os.walk(PATH):
        for f in filenames:
            fpath = os.path.join(dirpath, f)
            clear(fpath)
            expand(fpath, XPATH, ARGS.l)
