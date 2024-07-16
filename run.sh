SHELL_FOLDER=$(pwd)

$SHELL_FOLDER/build/qemu-system-riscv64 \
-M quard-star \
-m 1G \
-smp 8 \
-drive if=pflash,bus=0,unit=0,format=raw,file=$SHELL_FOLDER/lowlevelboot/fw.bin \
-nographic --parallel none

