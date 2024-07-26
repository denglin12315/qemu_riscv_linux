SHELL_FOLDER=$(pwd)
CROSS_PREFIX=/opt/riscv64--glibc--bleeding-edge-2020.08-1/bin/riscv64-linux

case $1 in
"qemu")
	#####################qemu compile
    cd $SHELL_FOLDER/qemu-6.0.0
	./configure --target-list=riscv64-softmmu --enable-gtk  --enable-virtfs --disable-gio --enable-debug
    make clean
	bear make -j
    cd -
;;
"dts")
    cd $SHELL_FOLDER/dts
    dtc -I dts -O dtb -o ./quard_star_sbi.dtb ./quard_star_sbi.dts
    dtc -I dts -O dtb -o ./quard_star_uboot.dtb ./quard_star_uboot.dts
    cd -
;;
"opensbi")
    cd $SHELL_FOLDER/opensbi-0.9
    make CROSS_COMPILE=$CROSS_PREFIX- PLATFORM=quard_star clean 
    make CROSS_COMPILE=$CROSS_PREFIX- PLATFORM=quard_star -j
    $CROSS_PREFIX-objdump --source --demangle --disassemble --reloc --wide $SHELL_FOLDER/opensbi-0.9/fw_jump.elf > $SHELL_FOLDER/opensbi-0.9/fw_jump.lst
    cd -
;;
"trusted_fw")
    cd $SHELL_FOLDER/trusted_fw
    $CROSS_PREFIX-gcc -x assembler-with-cpp -c startup.s -o $SHELL_FOLDER/trusted_fw/startup.o
    $CROSS_PREFIX-gcc -nostartfiles -T./link.lds -Wl,-Map=$SHELL_FOLDER/trusted_fw/trusted_fw.map -Wl,--gc-sections $SHELL_FOLDER/trusted_fw/startup.o -o $SHELL_FOLDER/trusted_fw/trusted_fw.elf
    $CROSS_PREFIX-objcopy -O binary -S $SHELL_FOLDER/trusted_fw/trusted_fw.elf $SHELL_FOLDER/trusted_fw/trusted_fw.bin
    $CROSS_PREFIX-objdump --source --demangle --disassemble --reloc --wide $SHELL_FOLDER/trusted_fw/trusted_fw.elf > $SHELL_FOLDER/trusted_fw/trusted_fw.lst
;;
"bl0")
	####################lowlevel start code compile
	cd $SHELL_FOLDER/bl0
	$CROSS_PREFIX-gcc -x assembler-with-cpp -c startup.s -o $SHELL_FOLDER/bl0/startup.o
	$CROSS_PREFIX-gcc -nostartfiles -T./boot.lds -Wl,-Map=$SHELL_FOLDER/bl0/bl0_fw.map -Wl,--gc-sections $SHELL_FOLDER/bl0/startup.o -o $SHELL_FOLDER/bl0/bl0_fw.elf
	$CROSS_PREFIX-objcopy -O binary -S $SHELL_FOLDER/bl0/bl0_fw.elf $SHELL_FOLDER/bl0/bl0_fw.bin
	$CROSS_PREFIX-objdump --source --demangle --disassemble --reloc --wide $SHELL_FOLDER/bl0/bl0_fw.elf > $SHELL_FOLDER/bl0/bl0_fw.lst

	#create new fw.bin
	rm -rf fw.bin
	dd of=fw.bin bs=1k count=32k if=/dev/zero
	dd of=fw.bin bs=1k conv=notrunc seek=0 if=bl0_fw.bin
    dd of=fw.bin bs=1k conv=notrunc seek=512 if=$SHELL_FOLDER/dts/quard_star_sbi.dtb
    dd of=fw.bin bs=1k conv=notrunc seek=1K if=$SHELL_FOLDER/dts/quard_star_uboot.dtb
    dd of=fw.bin bs=1k conv=notrunc seek=2K if=$SHELL_FOLDER/opensbi-0.9/build/platform/quard_star/firmware/fw_jump.bin
    dd of=fw.bin bs=1k conv=notrunc seek=4K if=$SHELL_FOLDER/trusted_fw/trusted_fw.bin
    dd of=fw.bin bs=1k conv=notrunc seek=8K if=$SHELL_FOLDER/u-boot-2021.07/u-boot.bin
	cd $SHELL_FOLDER
;;
"uboot")
    cd $SHELL_FOLDER/u-boot-2021.07
    make CROSS_COMPILE=$CROSS_PREFIX- qemu-quard-star_defconfig
    make CROSS_COMPILE=$CROSS_PREFIX- -j
    $CROSS_PREFIX-objdump --source --demangle --disassemble --reloc --wide $SHELL_FOLDER/u-boot-2021.07/u-boot > $SHELL_FOLDER/u-boot-2021.07/u-boot.lst
    cd -
;;
"clean")
    #cd $SHELL_FOLDER/qemu-6.0.0
    #./configure --target-list=riscv64-softmmu --enable-gtk  --enable-virtfs --disable-gio --enable-debug
    #make clean
    #cd -

    cd $SHELL_FOLDER/dts
    rm -rf ./quard_star_sbi.dtb
    cd -

    cd $SHELL_FOLDER/opensbi-0.9
    make CROSS_COMPILE=$CROSS_PREFIX- PLATFORM=quard_star clean
    cd -

    cd $SHELL_FOLDER/u-boot-2021.07
    make CROSS_COMPILE=$CROSS_PREFIX- distclean
    cd -

    cd $SHELL_FOLDER/bl0
    rm -rf *.o
    rm -rf *.bin
    rm -rf *.elf
    rm -rf *.lst
    cd -

    cd $SHELL_FOLDER/trusted_fw
    rm -rf *.o
    rm -rf *.bin
    rm -rf *.elf
    rm -rf *.lst
    cd -

    rm -rf fw.bin
;;
esac
