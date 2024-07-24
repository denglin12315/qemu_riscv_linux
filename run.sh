SHELL_FOLDER=$(pwd)

$SHELL_FOLDER/qemu-6.0.0/build/qemu-system-riscv64 \
-M quard-star \
-m 1G \
-smp 8 \
-drive if=pflash,bus=0,unit=0,format=raw,file=$SHELL_FOLDER/bl0/fw.bin \
-nographic --parallel none

