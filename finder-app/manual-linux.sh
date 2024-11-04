#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}
    
    #Clean kernel build tree
    echo "Clean kernel build tree"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper

    #Deconfig
    echo "Deconfig..."
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig

    #Build vmlinux
    echo "Build vmlinux..."
    make -j10 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all

    #Build modules
    #echo "Build modules..."
    #make -j10 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules

    #Build devicetree
    echo "Build devicetree..."
    make -j10 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs

fi

echo "Adding the Image in outdir"
cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}/

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

echo "Create roofts folder tree..."
mkdir -p ${OUTDIR}/rootfs
cd "$OUTDIR/rootfs"

mkdir -p bin dev etc root home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/lib usr/sbin
mkdir -p var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}

    echo "Configure Busybox..."
    make distclean
    make defconfig
   
else
    cd busybox

    echo "Configure Busybox..."
    make distclean
    make defconfig

fi

echo "Make and install busybox..."
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

cd "$OUTDIR/rootfs"

echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

echo "Add library dependencies to rootfs..."
cp ${SCRIPT_DIR}/../../../aarch64_crosscompile_toolchain/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib/
cp ${SCRIPT_DIR}/../../../aarch64_crosscompile_toolchain/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libm.so.6 ${OUTDIR}/rootfs/lib64/
cp ${SCRIPT_DIR}/../../../aarch64_crosscompile_toolchain/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libresolv.so.2 ${OUTDIR}/rootfs/lib64/
cp ${SCRIPT_DIR}/../../../aarch64_crosscompile_toolchain/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libc.so.6 ${OUTDIR}/rootfs/lib64/

echo "Clean and build the writer utility"
cd "$SCRIPT_DIR"
make clean
make CROSS_COMPILE=${CROSS_COMPILE}

ech "Copy the finder related scripts and executables to the /home directory on the target rootfs..."
cp $(dirname "$0")/writer ${OUTDIR}/rootfs/home/
cp $(dirname "$0")/finder.sh ${OUTDIR}/rootfs/home/
cp -r $(dirname "$0")/conf/ ${OUTDIR}/rootfs/home/
cp $(dirname "$0")/finder-test.sh ${OUTDIR}/rootfs/home/
cp $(dirname "$0")/autorun-qemu.sh ${OUTDIR}/rootfs/home/

echo "chown the root directory..."
sudo chown -R root ${OUTDIR}/rootfs/root

echo "Create initrmfs.cpio.gz..."
cd "$OUTDIR/rootfs"
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
cd "$OUTDIR"
gzip -f initramfs.cpio