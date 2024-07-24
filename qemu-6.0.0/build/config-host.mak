# Automatically generated by configure - do not modify

all:
GIT=git
GIT_SUBMODULES=ui/keycodemapdb tests/fp/berkeley-testfloat-3 tests/fp/berkeley-softfloat-3 meson dtc capstone slirp
GIT_SUBMODULES_ACTION=update
ARCH=x86_64
CONFIG_DEBUG_TCG=y
CONFIG_POSIX=y
CONFIG_LINUX=y
CONFIG_TOOLS=y
CONFIG_GUEST_AGENT=y
CONFIG_SMBD_COMMAND="/usr/sbin/smbd"
CONFIG_L2TPV3=y
CONFIG_AUDIO_DRIVERS=pa oss
CONFIG_AUDIO_PA=y
CONFIG_AUDIO_OSS=y
ALSA_LIBS=
ALSA_CFLAGS=
CONFIG_LIBPULSE=y
PULSE_LIBS=-lpulse
PULSE_CFLAGS=-D_REENTRANT
COREAUDIO_LIBS=-framework CoreAudio
DSOUND_LIBS=
OSS_LIBS=
JACK_LIBS=
CONFIG_BDRV_RW_WHITELIST=
CONFIG_BDRV_RO_WHITELIST=
PKGVERSION=
SRC_PATH=/home/ldeng/qemu_riscv_linux/qemu-6.0.0
TARGET_DIRS=riscv64-softmmu
CONFIG_PIPE2=y
CONFIG_ACCEPT4=y
CONFIG_SPLICE=y
CONFIG_EVENTFD=y
CONFIG_MEMFD=y
CONFIG_USBFS=y
CONFIG_FALLOCATE=y
CONFIG_FALLOCATE_PUNCH_HOLE=y
CONFIG_FALLOCATE_ZERO_RANGE=y
CONFIG_POSIX_FALLOCATE=y
CONFIG_SYNC_FILE_RANGE=y
CONFIG_FIEMAP=y
CONFIG_DUP3=y
CONFIG_PPOLL=y
CONFIG_PRCTL_PR_SET_TIMERSLACK=y
CONFIG_EPOLL=y
CONFIG_EPOLL_CREATE1=y
CONFIG_SENDFILE=y
CONFIG_TIMERFD=y
CONFIG_SETNS=y
CONFIG_CLOCK_ADJTIME=y
CONFIG_SYNCFS=y
CONFIG_INOTIFY=y
CONFIG_INOTIFY1=y
HAVE_STRCHRNUL=y
HAVE_STRUCT_STAT_ST_ATIM=y
CONFIG_BYTESWAP_H=y
CONFIG_TLS_PRIORITY="NORMAL"
CONFIG_QEMU_PRIVATE_XTS=y
HAVE_OPENPTY=y
HAVE_FSXATTR=y
HAVE_COPY_FILE_RANGE=y
CONFIG_VHOST_SCSI=y
CONFIG_VHOST_NET=y
CONFIG_VHOST_NET_USER=y
CONFIG_VHOST_NET_VDPA=y
CONFIG_VHOST_CRYPTO=y
CONFIG_VHOST_VSOCK=y
CONFIG_VHOST_USER_VSOCK=y
CONFIG_VHOST_KERNEL=y
CONFIG_VHOST_USER=y
CONFIG_VHOST_VDPA=y
CONFIG_VHOST_USER_FS=y
CONFIG_IOVEC=y
CONFIG_SIGNALFD=y
CONFIG_FDATASYNC=y
CONFIG_MADVISE=y
CONFIG_POSIX_MADVISE=y
CONFIG_POSIX_MEMALIGN=y
CONFIG_OPENGL=y
OPENGL_CFLAGS=
OPENGL_LIBS=-lepoxy
CONFIG_AVX2_OPT=y
CONFIG_QOM_CAST_DEBUG=y
CONFIG_COROUTINE_BACKEND=ucontext
CONFIG_COROUTINE_POOL=1
CONFIG_OPEN_BY_HANDLE=y
CONFIG_LINUX_MAGIC_H=y
CONFIG_HAS_ENVIRON=y
CONFIG_CPUID_H=y
CONFIG_INT128=y
CONFIG_CMPXCHG128=y
CONFIG_ATOMIC64=y
CONFIG_GETAUXVAL=y
CONFIG_LIVE_BLOCK_MIGRATION=y
CONFIG_TPM=y
TRACE_BACKENDS=log
CONFIG_TRACE_LOG=y
CONFIG_TRACE_FILE=trace
CONFIG_RTNETLINK=y
CONFIG_REPLICATION=y
CONFIG_AF_VSOCK=y
CONFIG_SYSMACROS=y
CONFIG_STATIC_ASSERT=y
HAVE_UTMPX=y
CONFIG_GETRANDOM=y
CONFIG_IVSHMEM=y
CONFIG_DEBUG_MUTEX=y
CONFIG_THREAD_SETNAME_BYTHREAD=y
CONFIG_PTHREAD_SETNAME_NP_W_TID=y
CONFIG_BOCHS=y
CONFIG_CLOOP=y
CONFIG_DMG=y
CONFIG_QCOW1=y
CONFIG_VDI=y
CONFIG_VVFAT=y
CONFIG_QED=y
CONFIG_PARALLELS=y
HAVE_MLOCKALL=y
HAVE_GDB_BIN=/usr/bin/gdb
CONFIG_SECRET_KEYRING=y
ROMS=optionrom
MAKE=make
PYTHON=/usr/bin/python3 -B
GENISOIMAGE=/usr/bin/genisoimage
MESON=/usr/bin/python3 -B /home/ldeng/qemu_riscv_linux/qemu-6.0.0/meson/meson.py
NINJA=/usr/bin/ninja
CC=cc
CXX=c++
OBJCC=cc
AR=ar
ARFLAGS=rv
AS=as
CCAS=cc
CPP=cc -E
OBJCOPY=objcopy
LD=ld
RANLIB=ranlib
NM=nm
PKG_CONFIG=pkg-config
WINDRES=windres
CFLAGS_NOPIE=-fno-pie
QEMU_CFLAGS=-m64 -mcx16 -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -Wstrict-prototypes -Wredundant-decls -Wundef -Wwrite-strings -Wmissing-prototypes -fno-strict-aliasing -fno-common -fwrapv  -Wold-style-declaration -Wold-style-definition -Wtype-limits -Wformat-security -Wformat-y2k -Winit-self -Wignored-qualifiers -Wempty-body -Wnested-externs -Wendif-labels -Wexpansion-to-defined -Wimplicit-fallthrough=2 -Wno-missing-include-dirs -Wno-shift-negative-value -Wno-psabi -fstack-protector-strong
QEMU_CXXFLAGS= -D__STDC_LIMIT_MACROS -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -m64 -mcx16 -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -Wundef -Wwrite-strings -fno-strict-aliasing -fno-common -fwrapv -Wtype-limits -Wformat-security -Wformat-y2k -Winit-self -Wignored-qualifiers -Wempty-body -Wendif-labels -Wexpansion-to-defined -Wimplicit-fallthrough=2 -Wno-missing-include-dirs -Wno-shift-negative-value -Wno-psabi -fstack-protector-strong
GLIB_CFLAGS=-pthread -I/usr/include/glib-2.0 -I/usr/lib/x86_64-linux-gnu/glib-2.0/include
GLIB_LIBS=-lgthread-2.0 -pthread -lglib-2.0
QEMU_LDFLAGS=-Wl,--warn-common -Wl,-z,relro -Wl,-z,now -m64  -fstack-protector-strong
LD_I386_EMULATION=elf_i386
EXESUF=
HOST_DSOSUF=.so
LIBS_QGA=
TASN1_LIBS=
TASN1_CFLAGS=
FUZZ_EXE_LDFLAGS=
CONFIG_QEMU_INTERP_PREFIX=/usr/gnemul/qemu-@0@
