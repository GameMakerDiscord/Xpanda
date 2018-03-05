#!/usr/bin/env python
# -*- coding: utf-8 -*-
import argparse
import os
import re

PATH_XSHADERS_DEFAULT = "./Xshaders/"
LANGS = ["glsl", "hlsl9", "hlsl11"]
LANG_DEFAULT = "glsl"

P_INCLUDE_START = r"#\s*pragma\s+include\s*\(\s*\"(?P<fname>[\w./]+)\"(\s*,\s*\"(?P<lang>\w+)\")?\s*\).*"
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
    elif lang.startswith("hlsl"):
        names = {
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
                    include_fname = m.group("fname").split("/")
                    include_fname = os.path.join(*include_fname)
                    include_lang = m.group("lang")
                    if include_lang:
                        if include_lang not in LANGS:
                            raise ValueError("Unknown language {}!".format(include_lang))
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
                            data += "// include(\"{}\")\n".format(m.group("fname"))
                else:
                    if level != 0:
                        data += handle_compatibility(l, lang)
                    else:
                        data += l

    do_expand(file)

    def remove_lang_specific(string, lang):
        l = "X" + lang.upper()
        pattern = r"#if " + l + "[\s\S]*#endif // " + l + "\n?"
        regex = re.compile(pattern)
        return regex.sub(lambda m: "", string)

    for l in LANGS:
        if lang == l:
            other = list(LANGS)
            other.remove(l)
            for o in other:
                data = remove_lang_specific(data, o)
            lang_upper = lang.upper()
            data = data.replace("#if X" + lang_upper + "\n", "")
            data = data.replace("\n#endif // X" + lang_upper, "")
            break

    if not lang.startswith("hlsl"):
        data = remove_lang_specific(data, "hlsl")
    else:
        data = data.replace("#if XHLSL\n", "")
        data = data.replace("\n#endif // XGLSL", "")

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
        "--l", metavar="LANG", type=str, default=LANG_DEFAULT, help="fallback shader language when not specified by include; options are: {} (default is {})".format(", ".join(LANGS), LANG_DEFAULT))

    ARGS = PARSER.parse_args()
    PATH = os.path.realpath(ARGS.path)
    XPATH = os.path.realpath(ARGS.x)

    if ARGS.l not in LANGS:
        print("Unknown language {}!".format(ARGS.l))
    else:
        for dirpath, dirnames, filenames in os.walk(PATH):
            for f in filenames:
                fpath = os.path.join(dirpath, f)
                clear(fpath)
                expand(fpath, XPATH, ARGS.l)
