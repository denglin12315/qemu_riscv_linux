SHELL_FOLDER=$(pwd)

case $1 in
"qemu")
	#####################qemu compile
	./configure --target-list=riscv64-softmmu --enable-gtk  --enable-virtfs --disable-gio --enable-debug
	bear make -j
;;
"start")
	####################lowlevel start code compile
	CROSS_PREFIX=/opt/riscv64-lp64d--glibc--bleeding-edge-2021.11-1/bin/riscv64-linux

	cd $SHELL_FOLDER/lowlevelboot
	$CROSS_PREFIX-gcc -x assembler-with-cpp -c startup.s -o $SHELL_FOLDER/lowlevelboot/startup.o
	$CROSS_PREFIX-gcc -nostartfiles -T./boot.lds -Wl,-Map=$SHELL_FOLDER/lowlevelboot/lowlevel_fw.map -Wl,--gc-sections $SHELL_FOLDER/lowlevelboot/startup.o -o $SHELL_FOLDER/lowlevelboot/lowlevel_fw.elf
	$CROSS_PREFIX-objcopy -O binary -S $SHELL_FOLDER/lowlevelboot/lowlevel_fw.elf $SHELL_FOLDER/lowlevelboot/lowlevel_fw.bin
	$CROSS_PREFIX-objdump --source --demangle --disassemble --reloc --wide $SHELL_FOLDER/lowlevelboot/lowlevel_fw.elf > $SHELL_FOLDER/lowlevelboot/lowlevel_fw.lst

	#create new fw.bin
	rm -rf fw.bin
	dd of=fw.bin bs=1k count=32k if=/dev/zero
	dd of=fw.bin bs=1k conv=notrunc seek=0 if=lowlevel_fw.bin
	cd $SHELL_FOLDER
;;
esac
