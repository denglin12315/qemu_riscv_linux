SHELL_FOLDER=$(pwd)

$SHELL_FOLDER/build/qemu-system-riscv64 \
-M quard-star \
-m 1G \
-smp 8 \
-nographic --parallel none

