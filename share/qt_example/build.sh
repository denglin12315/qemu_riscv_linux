SHELL_FOLDER=$(pwd)
CROSS_COMPILE_DIR=/opt/riscv64--glibc--bleeding-edge-2020.08-1
CROSS_QT_TOOLS_DIR=$1
export PATH=$PATH:$CROSS_COMPILE_DIR/bin

cd $SHELL_FOLDER/analogclock
$CROSS_QT_TOOLS_DIR/bin/qmake -makefile
make -j2

cd $SHELL_FOLDER/rasterwindow
$CROSS_QT_TOOLS_DIR/bin/qmake -makefile
make -j2
