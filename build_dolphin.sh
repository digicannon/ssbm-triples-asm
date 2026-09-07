#!/bin/sh
# Dolphin build: DEBUG on (no adapter; P5/P6 mirror P1/P2) and 16MB ARAM
# with a smaller AllA heap, since Dolphin cannot grow ARAM.  Writes the
# codes into Dolphin's GALE01.ini.
set -e
(cd ~/src/asm2memcard && go build -o a2m .)
tmp=$(mktemp -d)
cp -r asm src assets triples.a2m "$tmp"
cd "$tmp"
sed -i 's/^\.set DEBUG, 0/.set DEBUG, 1/' asm/triples.s
sed -i '/^@set 015684 3C000180$/d; /^@set 01568C 60000000$/d; s/^@set 3BA3BC 00D6C800$/@set 3BA3BC 0083C800/' triples.a2m
PATH=/opt/devkitpro/devkitPPC/bin:$PATH ~/src/asm2memcard/a2m --dolphin --clean --no-loader triples.a2m ~/.local/share/dolphin-emu/GameSettings/GALE01.ini
rm -rf "$tmp"
