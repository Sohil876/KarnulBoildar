#!/bin/bash
### START_CONFIG ###
KERNEL_LINK=https://github.com/MASTERGUY/kernel_xiaomi_msm8953
KERNEL_BRANCH=derp10
KERNEL_NAME=Perf
CLANG_REPO=https://github.com/kdrag0n/proton-clang
#CLANG_REPO=https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86
CLANG_BRANCH=master
GCC_DIR="" # Doesn't needed if use proton-clang
GCC32_DIR="" # Doesn't needed if use proton-clang
COMP_TYPE="clang" # unset if want to use gcc as compiler
### END_CONFIG ###
echo "Cloning dependencies"
git clone --depth=1 -b $KERNEL_BRANCH $KERNEL_LINK kernel
cd kernel
git clone --depth=1 -b $CLANG_BRANCH $CLANG_REPO clang
git clone https://github.com/MASTERGUY/AnyKernel3 -b tissot --depth=1 AnyKernel
echo "Done"
KERNEL_DIR=$(pwd)
#IMAGE="${KERNEL_DIR}/out/arch/arm64/boot/Image.gz-dtb"
DTB_TYPE="" # define as "single" if want use single file
KERN_IMG="${KERNEL_DIR}"/out/arch/arm64/boot/Image.gz-dtb             # if use single file define as Image.gz-dtb instead
KERN_DTB="${KERNEL_DIR}"/out/arch/arm64/boot/dtbo.img # and comment this variable
TANGGAL=$(date +"%Y%m%d-%H")
PARSE_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
PARSE_ORIGIN="$(git config --get remote.origin.url)"
COMMIT_POINT="$(git log --pretty=format:'%h : %s' -1)"
export PATH="$(pwd)/clang/bin:$PATH"
#export KBUILD_COMPILER_STRING="$($kernel/clang/bin/clang --version | head -n 1 | perl -pe 's/\((?:http|git).*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' -e 's/^.*clang/clang/')"
export KBUILD_COMPILER_STRING=$("$kernel"/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
export ARCH=arm64
export KBUILD_BUILD_USER=Sohil876
export KBUILD_BUILD_HOST=TheBishBuilder
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
