SHELL_FOLDER=$(pwd)
DEFAULT_VC="1280x720"

$SHELL_FOLDER/qemu-6.0.0/build/qemu-system-riscv64 \
-M quard-star \
-m 1G \
-smp 8 \
-drive if=pflash,bus=0,unit=0,format=raw,file=$SHELL_FOLDER/bl0/fw.bin \
-drive file=$SHELL_FOLDER/rootfs/rootfs.img,format=raw,id=hd0 \
-device virtio-blk-device,drive=hd0 \
-fw_cfg name="opt/qemu_cmdline",string="qemu_vc="$DEFAULT_V"" \
--serial vc:$DEFAULT_VC --serial vc:$DEFAULT_VC --serial vc:$DEFAULT_VC --monitor vc:$DEFAULT_VC --parallel none

