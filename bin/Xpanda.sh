#!/usr/bin/env bash
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
source "$SCRIPTPATH/../env/bin/activate"
"$SCRIPTPATH/../Xpanda.py" "$@"
