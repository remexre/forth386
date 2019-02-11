#!/bin/bash

set -eu

LOWER="${1}"
UPPER="${2}"
MIDDLE="$(( (${LOWER} + ${UPPER}) / 2 ))"

CMD='qemu-system-i386 -S -gdb stdio -m 64M -drive format=raw,file=out/forth386.img'

gdb -ex "target remote | ${CMD}"    \
	-ex "break *${LOWER}"           \
	-ex "break *$((${LOWER} + 1))"  \
	-ex "break *${MIDDLE}"          \
	-ex "break *$((${MIDDLE} + 1))" \
	-ex "break *${UPPER}"           \
	-ex "break *$((${UPPER} + 1))"  \
	-ex "continue"
