#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
build_dir="$(mktemp -d)"
trap 'rm -rf -- "$build_dir"' EXIT

nasm -f elf32 "$script_dir/FLAB3.asm" -o "$build_dir/FLAB3.o"
ld -m elf_i386 "$build_dir/FLAB3.o" -o "$build_dir/FLAB3"
"$build_dir/FLAB3"
