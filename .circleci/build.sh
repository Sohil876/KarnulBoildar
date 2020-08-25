#!/bin/bash
### START_CONFIG ###
KERNEL_LINK=https://github.com/prorooter007/Android_Kernel_Xiaomi_msm8953
KERNEL_BRANCH=cleanlosreb
KERNEL_NAME=LightningRebased
KERNEL_CONF_FILE=https://raw.githubusercontent.com/DerpFest-Devices/kernel_xiaomi_msm8953/derp10/arch/arm64/configs/tissot_defconfig
KERNEL_MAKE_FILE=https://raw.githubusercontent.com/Sohil876/KarnulBoildar/master/Makefile
CLANG_SELECTED=https://github.com/kdrag0n/proton-clang
#CLANG_SELECTED=https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86
CLANG_BRANCH=master
### END_CONFIG ###
echo "Cloning dependencies"
git clone --depth=1 -b $KERNEL_BRANCH $KERNEL_LINK kernel
git clone --depth=1 -b $CLANG_BRANCH $CLANG_SELECTED kernel/clang
git clone https://github.com/MASTERGUY/AnyKernel3 -b tissot --depth=1 kernel/AnyKernel
cd kernel
#rm Makefile
#wget $KERNEL_MAKE_FILE -O Makefile
#wget $KERNEL_CONF_FILE -O arch/arm64/configs/tissot_defconfig
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
#    make -j$(nproc) O=out ARCH=arm64 msm8953_defconfig
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
