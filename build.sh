SHELL_FOLDER=$(pwd)
CROSS_PATH=/opt/riscv64--glibc--bleeding-edge-2020.08-1/riscv64-buildroot-linux-gnu/sysroot
CROSS_PREFIX=/opt/riscv64--glibc--bleeding-edge-2020.08-1/bin/riscv64-linux

case $1 in
"linux")
    cd $SHELL_FOLDER/linux-5.10.42
    make ARCH=riscv CROSS_COMPILE=$CROSS_PREFIX- quard_star_defconfig
    bear make ARCH=riscv CROSS_COMPILE=$CROSS_PREFIX- -j1
    cd -
;;
"linux_clean")
    cd $SHELL_FOLDER/linux-5.10.42
    make ARCH=riscv CROSS_COMPILE=$CROSS_PREFIX- distclean
    cd -
;;
"qemu")
	#####################qemu compile
	cd $SHELL_FOLDER/qemu-6.0.0
	./configure --target-list=riscv64-softmmu --enable-gtk  --enable-virtfs --disable-gio --enable-debug
	make clean
	bear make -j
	cd -
;;
"qemu_clean")
    cd $SHELL_FOLDER/qemu-6.0.0
	./configure --target-list=riscv64-softmmu --enable-gtk  --enable-virtfs --disable-gio --enable-debug
    make clean
    cd -
;;
"dts")
    cd $SHELL_FOLDER/dts
    dtc -I dts -O dtb -o ./quard_star_sbi.dtb ./quard_star_sbi.dts
    dtc -I dts -O dtb -o ./quard_star_uboot.dtb ./quard_star_uboot.dts
    cd -
;;
"dts_clean")
    cd $SHELL_FOLDER/dts
    rm -rf *.dtb
    cd -
;;
"opensbi")
    cd $SHELL_FOLDER/opensbi-0.9
    make CROSS_COMPILE=$CROSS_PREFIX- PLATFORM=quard_star clean 
    rm -rf ./build
    bear make CROSS_COMPILE=$CROSS_PREFIX- PLATFORM=quard_star -j
    $CROSS_PREFIX-objdump --source --demangle --disassemble --reloc --wide $SHELL_FOLDER/opensbi-0.9/build/platform/quard_star/firmware/fw_jump.elf > $SHELL_FOLDER/opensbi-0.9/fw_jump.lst
    cd -
;;
"opensbi_clean")
    cd $SHELL_FOLDER/opensbi-0.9
    make CROSS_COMPILE=$CROSS_PREFIX- PLATFORM=quard_star clean 
    rm -rf ./build
    rm -rf opensbi-0.9/fw_jump.lst
    cd -
;;
"trusted_fw")
    cd $SHELL_FOLDER/trusted_fw
    $CROSS_PREFIX-gcc -x assembler-with-cpp -c startup.s -o $SHELL_FOLDER/trusted_fw/startup.o
    $CROSS_PREFIX-gcc -nostartfiles -T./link.lds -Wl,-Map=$SHELL_FOLDER/trusted_fw/trusted_fw.map -Wl,--gc-sections $SHELL_FOLDER/trusted_fw/startup.o -o $SHELL_FOLDER/trusted_fw/trusted_fw.elf
    $CROSS_PREFIX-objcopy -O binary -S $SHELL_FOLDER/trusted_fw/trusted_fw.elf $SHELL_FOLDER/trusted_fw/trusted_fw.bin
    $CROSS_PREFIX-objdump --source --demangle --disassemble --reloc --wide $SHELL_FOLDER/trusted_fw/trusted_fw.elf > $SHELL_FOLDER/trusted_fw/trusted_fw.lst
    cd -
;;
"trusted_fw_clean")
    cd $SHELL_FOLDER/trusted_fw
    rm -rf *.o
    rm -rf *.bin
    rm -rf *.elf
    rm -rf *.lst
    cd -
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
;;
"bl0_clean")
    cd $SHELL_FOLDER/bl0
    rm -rf *.o
    rm -rf *.bin
    rm -rf *.elf
    rm -rf *.lst
    cd -
;;
"fs")
    cd $SHELL_FOLDER/fs
    rm -rf ./rootfs/rootfs.img
    rm -rf ./rootfs/fake_init/init
    $CROSS_PREFIX-gcc ./rootfs/fake_init/fake_init.c -lpthread -static -o ./rootfs/fake_init/init
    dd if=/dev/zero of=./rootfs/rootfs.img bs=1M count=1024
    sleep 3
    pkexec $SHELL_FOLDER/fs/generate_rootfs.sh $SHELL_FOLDER/fs/rootfs/rootfs.img $SHELL_FOLDER/fs/sfdisk
    sleep 3
    cp $SHELL_FOLDER/linux-5.10.42/arch/riscv/boot/Image $SHELL_FOLDER/fs/bootfs/Image
    cp $SHELL_FOLDER/dts/quard_star_uboot.dtb $SHELL_FOLDER/fs/bootfs/quard_star.dtb
    $SHELL_FOLDER/u-boot-2021.07/tools/mkimage -A riscv -O linux -T script -C none -a 0 -e 0 -n "Distro Boot Script" -d $SHELL_FOLDER/dts/quard_star_uboot.cmd $SHELL_FOLDER/fs/bootfs/boot.scr
    pkexec $SHELL_FOLDER/fs/build.sh $SHELL_FOLDER/fs $CROSS_PATH
    cd -
;;
"qt")
	cd $SHELL_FOLDER/qt-everywhere-src-5.15.10
	./build.sh $SHELL_FOLDER/fs/app/
	cd -
;;

"qt_clean")
	rm -rf $SHELL_FOLDER/fs/app/qt-5.15.10
;;

"qt_exp")
	cd $SHELL_FOLDER/share/qt_example
	./build.sh $SHELL_FOLDER/fs/app/qt-5.12.12
	cd -
;;

"busybox")
	cd $SHELL_FOLDER/busybox-1.33.1
	make ARCH=riscv CROSS_COMPILE=$CROSS_PREFIX- mrproper
	make ARCH=riscv CROSS_COMPILE=$CROSS_PREFIX- quard_star_defconfig
	bear make ARCH=riscv CROSS_COMPILE=$CROSS_PREFIX- -j
	make ARCH=riscv CROSS_COMPILE=$CROSS_PREFIX- install
	cp -r $SHELL_FOLDER/output/busybox/* $SHELL_FOLDER/fs/rootfs/
	rm -rf $SHELL_FOLDER/output
	cd -
;;
"busybox_clean")
    cd $SHELL_FOLDER/busybox-1.33.1
    make ARCH=riscv CROSS_COMPILE=$CROSS_PREFIX- mrproper
    rm -rf $SHELL_FOLDER/output
    cd -
;;
"uboot")
    cd $SHELL_FOLDER/u-boot-2021.07
    make CROSS_COMPILE=$CROSS_PREFIX- qemu-quard-star_defconfig
    bear make CROSS_COMPILE=$CROSS_PREFIX- -j
    $CROSS_PREFIX-objdump --source --demangle --disassemble --reloc --wide $SHELL_FOLDER/u-boot-2021.07/u-boot > $SHELL_FOLDER/u-boot-2021.07/u-boot.lst
    cd -
;;
"uboot_clean")
    cd $SHELL_FOLDER/u-boot-2021.07
    make CROSS_COMPILE=$CROSS_PREFIX- clean
    rm -rf u-boot.lst
    cd -
;;
"clean")
    cd $SHELL_FOLDER/qemu-6.0.0
    ./configure --target-list=riscv64-softmmu --enable-gtk  --enable-virtfs --disable-gio --enable-debug
    make clean
    cd -

    cd $SHELL_FOLDER/dts
    rm -rf ./*.dtb
    cd -

    cd $SHELL_FOLDER/opensbi-0.9
    make CROSS_COMPILE=$CROSS_PREFIX- PLATFORM=quard_star clean
    rm -rf fw_jump.lst
    cd -

    cd $SHELL_FOLDER/u-boot-2021.07
    make CROSS_COMPILE=$CROSS_PREFIX- distclean
    rm -rf u-boot.lst
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

    cd $SHELL_FOLDER/rootfs
    rm -rf rootfs.img
    cd -

    rm -rf fw.bin
;;
esac
