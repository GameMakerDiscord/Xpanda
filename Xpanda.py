#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import argparse
import os
import re

from src.common import *
from src.legacy import *
from src.preprocessor import Preprocessor
from src.tokenizer import tokenize

PATH_XSHADERS_DEFAULT = "./Xshaders/"

LANG_DEFAULT = "glsl"


if __name__ == "__main__":
    PARSER = argparse.ArgumentParser(
        description="Include code from external files into your shaders.")
    PARSER.add_argument(
        "path", metavar="PATH", type=str, help="path to the folder containing your shaders")
    PARSER.add_argument(
        "--x", metavar="EXTERNAL", type=str, default=PATH_XSHADERS_DEFAULT, help="path to the folder containing the external files (default is {})".format(PATH_XSHADERS_DEFAULT))
    PARSER.add_argument(
        "--o", metavar="OUT", type=str, default="", help="output directory for expanded shaders; PATH is used if not specified")
    PARSER.add_argument(
        "--l", metavar="LANG", type=str, default=LANG_DEFAULT, help="fallback shader language when not specified by include; options are: {} (default is {})".format(", ".join(LANGS), LANG_DEFAULT))

    ARGS = PARSER.parse_args()
    PATH = os.path.realpath(ARGS.path)
    XPATH = os.path.realpath(ARGS.x)
    OPATH = os.path.realpath(ARGS.o) if ARGS.o else PATH

    if ARGS.l not in LANGS:
        print("Unknown language {}!".format(ARGS.l))
        exit()

    env = {
        "XGLSL": ARGS.l == "glsl",
        "XHLSL": ARGS.l in ["hlsl9", "hlsl11"],
        "XHLSL9": ARGS.l == "hlsl9",
        "XHLSL11": ARGS.l == "hlsl11"
    }

    try:
        for dirpath, dirnames, filenames in os.walk(PATH):
            for f in filenames:
                fin = os.path.join(dirpath, f)
                fout_dir = os.path.join(OPATH, dirpath[len(PATH) + 1:])
                fout = os.path.join(fout_dir, f)
                clear(fin)
                expand(f, dirpath, XPATH, fout_dir, ARGS.l)
                tokens = tokenize(fout)
                processed = Preprocessor(tokens, env).process()
                with open(fout, "w") as f:
                    f.write(processed)

    except KeyboardInterrupt:
        # Ignore Ctrl+C
        print()
    except Exception as e:
        print("ERROR:", str(e))
