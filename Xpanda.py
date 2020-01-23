#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import copy
import os
import sys
import traceback

from src.common import *
from src.legacy import *
from src.preprocessor import Preprocessor
from src.tokenizer import tokenize

PATH_XSHADERS_DEFAULT = "./Xshaders/"

LANG_DEFAULT = "glsl"


def print_help():
    print((
        "Usage: Xpanda [-h] PATH [--x EXTERNAL] [--o OUT] [--l LANG] [--m MINIFY] [CONSTANT=value ...]\n"
        "\n"
        "Includes code from external files into your shaders.\n"
        "\n"
        "Arguments:\n"
        "\n"
        "  -h             - Shows this help message.\n"
        "  PATH           - Path to the folder containing your shaders.\n"
        "  EXTERNAL       - Path to the folder containing the external files (default is {external}).\n"
        "  OUT            - Output directory for expanded shaders, PATH is used if not specified.\n"
        "  LANG           - Fallback shader language when not specified by include.\n"
        "                   Options are: {langs} (default is {lang_def}).\n"
        "  MINIFY         - Enable minification. This removes comments and whitespace.\n"
        "                   Possible values are:\n"
        "                     - 0 - No minification. Leave code as it is.\n"
        "                     - 1 - Minify only code from included files. [NOT YET SUPPORTED!]\n"
        "                     - 2 - Minify everything.\n"
        "  CONSTANT=value - Custom constant definition. Values can be either numbers, booleans or\n"
        "                   any string. Maximum number of constants is not limited.\n"
    ).format(
        external=PATH_XSHADERS_DEFAULT,
        langs=", ".join(LANGS),
        lang_def=LANG_DEFAULT,
    ))


if __name__ == "__main__":
    argc = len(sys.argv)

    PATH = None
    XPATH = os.path.realpath(PATH_XSHADERS_DEFAULT)
    OPATH = ""
    LANG_CURRENT = "glsl"
    ENV = {}
    MINIFY = False

    index = 1
    try:
        while index < argc:
            arg = sys.argv[index]

            if arg == "-h":
                print_help()
                exit()
            elif arg == "--x":
                index += 1
                XPATH = os.path.realpath(sys.argv[index])
            elif arg == "--m":
                index += 1
                MINIFY = int(sys.argv[index]) >= 2
            elif arg == "--o":
                index += 1
                OPATH = os.path.realpath(sys.argv[index])
            elif arg == "--l":
                index += 1
                LANG_CURRENT = sys.argv[index]
            elif arg.count("=") == 1:
                k, v = arg.split("=", 1)
                try:
                    v = int(v)
                except:
                    if v == "true":
                        v = True
                    elif v == "false":
                        v = False
                ENV[k] = v
            elif not PATH:
                p = os.path.realpath(arg)
                if os.path.isdir(p) or os.path.isfile(p):
                    PATH = p
            else:
                raise Exception(
                    "Unknown argument {}! Use -h to show help message.".format(arg))

            index += 1
    except IndexError:
        print("ERROR: No value defined for argument {}!".format(
            sys.argv[index - 1]))
        exit()
    except Exception as e:
        print("ERROR:", e)
        exit()

    if PATH is None:
        print("Argument PATH must be a directory or a file! Use -h to show help message.")
        exit()

    OPATH = os.path.realpath(OPATH) if OPATH else PATH

    if LANG_CURRENT not in LANGS:
        print("Unknown language {}!".format(LANG_CURRENT))
        exit()

    def _process_file(fin, fout):
        clear(fin)
        _lang = expand(fin, XPATH, fout, LANG_CURRENT)

        _env = copy.deepcopy(ENV)
        _env["XGLSL"] = _lang == "glsl"
        _env["XHLSL"] = _lang in ["hlsl9", "hlsl11"]
        _env["XHLSL9"] = _lang == "hlsl9"
        _env["XHLSL11"] = _lang == "hlsl11"

        tokens = tokenize(fout)
        processed = Preprocessor(tokens, env=_env, minify=MINIFY).process()
        with open(fout, "w") as f:
            f.write(processed)
        print("-" * 80)

    try:
        if os.path.isfile(PATH):
            _process_file(PATH, OPATH)
        else:
            for dirpath, dirnames, filenames in os.walk(PATH):
                for f in filenames:
                    _process_file(
                        os.path.join(dirpath, f),
                        os.path.join(OPATH, f))

    except KeyboardInterrupt:
        # Ignore Ctrl+C
        print()
    except Exception as e:
        print("ERROR:", str(e))
        print(traceback.format_exc())
