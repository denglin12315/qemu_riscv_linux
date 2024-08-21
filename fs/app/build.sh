SHELL_FOLDER=$(pwd)
CROSS_COMPILE_DIR=/opt/riscv64--glibc--bleeding-edge-2020.08-1
CROSS_PREFIX=$CROSS_COMPILE_DIR/bin/riscv64-linux

case "$1" in
clean)
	CONFIGURE=./configure
	# 编译bash
	cd $SHELL_FOLDER/bash-5.2
	$CONFIGURE --host=riscv64 --prefix=$2 CXX=$CROSS_PREFIX-g++ CC=$CROSS_PREFIX-gcc
	make distclean
	cd -

	# 编译make
	cd $SHELL_FOLDER/make-4.3
	$CONFIGURE --host=riscv64 --prefix=$2 CXX=$CROSS_PREFIX-g++ CC=$CROSS_PREFIX-gcc 
	make distclean
	cd -

	# 编译ncurses
	cd $SHELL_FOLDER/ncurses-6.2
	$CONFIGURE --host=riscv64 --prefix=$2 --disable-stripping CXX=$CROSS_PREFIX-g++ CC=$CROSS_PREFIX-gcc 
	make distclean
	cd -

	cd $SHELL_FOLDER/sudo-1.9.7p1
	./configure --host=riscv --prefix=$2 CXX=$CROSS_PREFIX-g++ CC=$CROSS_PREFIX-gcc 
	make distclean
	cd -

	;;
build)
	CONFIGURE=./configure
	# 编译bash
	cd $SHELL_FOLDER/bash-5.2
	$CONFIGURE --host=riscv64 --prefix=$2 CXX=$CROSS_PREFIX-g++ CC=$CROSS_PREFIX-gcc
	make -j16
	make install
	cd -

	# 编译make
	cd $SHELL_FOLDER/make-4.3
	$CONFIGURE --host=riscv64 --prefix=$2 CXX=$CROSS_PREFIX-g++ CC=$CROSS_PREFIX-gcc 
	make -j16
	make install
	cd -
	# 编译ncurses
	cd $SHELL_FOLDER/ncurses-6.2
	$CONFIGURE --host=riscv64 --prefix=$2 --disable-stripping CXX=$CROSS_PREFIX-g++ CC=$CROSS_PREFIX-gcc 
	make -j16
	make install.progs
	make install.data
	cd -
	# 编译sudo
	cd $SHELL_FOLDER/sudo-1.9.7p1
	./configure --host=riscv --prefix=$2 CXX=$CROSS_PREFIX-g++ CC=$CROSS_PREFIX-gcc 
	make -j16
	make install-binaries
	cd -
	# 编译zlib
	cd $SHELL_FOLDER/zlib-1.3.1
	export CC=$CROSS_PREFIX-gcc
	./configure --prefix=$2
	make -j2
	make install
	cd -
	# 编译openssl
	cd $SHELL_FOLDER/openssl-3.0.0
	export CC=$CROSS_PREFIX-gcc
	./configure linux-generic64 no-asm --prefix=$2 --cross-compile-prefix=$CROSS_PREFIX-
	make -j2
	make install_sw
	cd -

	# 编译openssh
	cd $SHELL_FOLDER/ssh
	./configure --host=riscv64-linux-gnu --with-openssl=$2 --with-zlib=$2 CXX=$CROSS_PREFIX-g++ CC=$CROSS_PREFIX-gcc
	make -j2
	make install
	cd -

	# cp qt lib to rootfs /opt dir
	mkdir -p $2/opt/qt-5.15.10
	cp -a $SHELL_FOLDER/qt-5.15.10/* $2/opt/qt-5.15.10

	;;
*)

	echo "invalid build cmd for app build.sh"
	;;
esac

