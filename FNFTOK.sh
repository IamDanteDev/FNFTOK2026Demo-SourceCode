#!/bin/sh
printf '\033c\033]0;%s\a' Friday Night Funkin'- The Origami King DEMO
base_path="$(dirname "$(realpath "$0")")"
"$base_path/FNFTOK.x86_64" "$@"
