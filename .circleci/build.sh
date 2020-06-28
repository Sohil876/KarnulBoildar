#!/bin/bash
### START_CONFIG ###
KERNEL_LINK=https://github.com/LineageOS/android_kernel_xiaomi_msm8953
KERNEL_BRANCH=lineage-17.1
KERNEL_NAME=LineageCL
KERNEL_CONF_FILE=https://raw.githubusercontent.com/DerpFest-Devices/kernel_xiaomi_msm8953/derp10/arch/arm64/configs/tissot_defconfig
### END_CONFIG ###
echo "Cloning dependencies"
git clone --depth=1 -b $KERNEL_BRANCH $KERNEL_LINK kernel
cd kernel
#wget $KERNEL_CONF_FILE -O arch/arm64/configs/tissot_defconfig
git clone --depth=1 -b master https://github.com/kdrag0n/proton-clang clang
git clone https://github.com/MASTERGUY/AnyKernel3 -b tissot --depth=1 AnyKernel
echo "Done"
KERNEL_DIR=$(pwd)
IMAGE="${KERNEL_DIR}/out/arch/arm64/boot/Image.gz-dtb"
TANGGAL=$(date +"%Y%m%d-%H")
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
export PATH="$(pwd)/clang/bin:$PATH"
export KBUILD_COMPILER_STRING="$($kernel/clang/bin/clang --version | head -n 1 | perl -pe 's/\((?:http|git).*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' -e 's/^.*clang/clang/')"
export ARCH=arm64
export KBUILD_BUILD_USER=Sohil876
export KBUILD_BUILD_HOST=CircleCI
# Compile plox
function compile() {
    make -j$(nproc) O=out ARCH=arm64 tissot_defconfig
    make -j$(nproc) O=out \
                    ARCH=arm64 \
                      CC=clang \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \

    if ! [ -a "$IMAGE" ]; then
        exit 1
        echo "There are some issues"
    fi
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}
# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 $KERNEL_NAME-Kernel-${TANGGAL}.zip *
    curl https://bashupload.com/${KERNEL_NAME}-Kernel-${TANGGAL}.zip --data-binary @${KERNEL_NAME}-Kernel-${TANGGAL}.zip
}
compile
zipping
