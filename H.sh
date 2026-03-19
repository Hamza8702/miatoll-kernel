#!/bin/bash
# Kernel build script for Miatoll - Clean Version

set -e
set -o pipefail

# Configuration
export ARCH=arm64
export KBUILD_BUILD_HOST=GitHub-Actions
export KBUILD_BUILD_USER="Hamza8702"
TIMESTAMP=$(date +"%Y%m%d-%H")
OUT_DIR="out"

# 1. Setup Toolchains
setup_toolchains() {
    echo "--> Cloning toolchains..."
    [ ! -d "clang" ] && git clone --depth=1 https://github.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-6443078 clang
    [ ! -d "gcc64" ] && git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 gcc64
    [ ! -d "gcc32" ] && git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 gcc32
}

export PATH="${PWD}/clang/bin:${PWD}/gcc64/bin:${PWD}/gcc32/bin:${PATH}"

# 2. Compile Kernel
compile_kernel() {
    echo "--> Starting configuration..."
    mkdir -p $OUT_DIR
    
    CONF_FILE=$(find arch/arm64/configs/ -name "miatoll.config" -o -name "miatoll_defconfig" | head -n 1)
    
    if [ -n "$CONF_FILE" ]; then
        FINAL_CONF=$(echo $CONF_FILE | sed 's|arch/arm64/configs/||')
        echo "--> Found Config: $FINAL_CONF"
        make -j$(nproc --all) O=$OUT_DIR ARCH=arm64 "$FINAL_CONF"
    else
        echo "--> ERROR: No config found!"
        exit 1
    fi

    echo "--> Starting compilation..."
    make -j$(nproc --all) O=$OUT_DIR \
                      ARCH=arm64 \
                      CC="clang" \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE="aarch64-linux-android-" \
                      CROSS_COMPILE_ARM32="arm-linux-androideabi-" \
                      LD=ld.lld \
                      CONFIG_NO_ERROR_ON_MISMATCH=y
}

# 3. Packaging
package_kernel() {
    ZIMAGE=""
    [ -f "$OUT_DIR/arch/arm64/boot/Image.gz" ] && ZIMAGE="$OUT_DIR/arch/arm64/boot/Image.gz"
    [ -f "$OUT_DIR/arch/arm64/boot/Image" ] && [ -z "$ZIMAGE" ] && ZIMAGE="$OUT_DIR/arch/arm64/boot/Image"

    if [ -n "$ZIMAGE" ]; then
        echo "--> Kernel compiled successfully!"
        git clone --depth=1 https://github.com/Amritorock/AnyKernel3 -b r5x AnyKernel
        cp "$ZIMAGE" AnyKernel/
        cd AnyKernel
        zip -r9 "../Stormbreaker-miatoll-${TIMESTAMP}.zip" *
        cd ..
    else
        echo "--> Error: Kernel image not found!"
        exit 1
    fi
}

setup_toolchains
compile_kernel
package_kernel
