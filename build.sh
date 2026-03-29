#!/bin/bash
# Kernel build script for Miatoll

set -e

# Configuration
export ARCH=arm64
export KBUILD_BUILD_HOST=GitHub-Actions
export KBUILD_BUILD_USER="Hamza8702"
TIMESTAMP=$(date +"%Y%m%d-%H")
OUT_DIR="out"

# Clone Toolchains if not exist
setup_toolchains() {
    echo "--> Cloning toolchains..."
    if [ ! -d "clang" ]; then
        git clone --depth=1 https://github.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-6443078 clang
    fi
    if [ ! -d "gcc64" ]; then
        git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 gcc64
    fi
    if [ ! -d "gcc32" ]; then
        git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 gcc32
    fi
}

# Export Paths
export PATH="${PWD}/clang/bin:${PWD}/gcc64/bin:${PWD}/gcc32/bin:${PATH}"

# Compile Function
compile_kernel() {
    echo "--> Starting configuration..."
    mkdir -p $OUT_DIR
    
    # Generate .config (Checking for specific vendor path)
    make -j$(nproc --all) O=$OUT_DIR ARCH=arm64 vendor/Xiaomi/miatoll_defconfig

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

# Packaging Function
package_kernel() {
    ZIMAGE="$OUT_DIR/arch/arm64/boot/Image.gz"
    if [ -f "$ZIMAGE" ]; then
        echo "--> Kernel compiled successfully!"
        git clone --depth=1 https://github.com/Amritorock/AnyKernel3 -b r5x AnyKernel
        cp "$ZIMAGE" AnyKernel/
        cd AnyKernel
        zip -r9 "../Stormbreaker-miatoll-${TIMESTAMP}.zip" *
        cd ..
        echo "--> Zip created: Stormbreaker-miatoll-${TIMESTAMP}.zip"
    else
        echo "--> Error: Kernel image not found!"
        exit 1
    fi
}

setup_toolchains
compile_kernel
package_kernel


[]()#!/bin/bash
# Kernel build script for Miatoll

set -e

# Configuration
export ARCH=arm64
export KBUILD_BUILD_HOST=GitHub-Actions
export KBUILD_BUILD_USER="Hamza8702"
TIMESTAMP=$(date +"%Y%m%d-%H")
OUT_DIR="out"

# Clone Toolchains if not exist
setup_toolchains() {
    echo "--> Cloning toolchains..."
    if [ ! -d "clang" ]; then
        git clone --depth=1 https://github/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-6443078 clang
    fi
    if [ ! -d "gcc64" ]; then
        git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 gcc64
    fi
    if [ ! -d "gcc32" ]; then
        git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 gcc32
    fi
}

# Export Paths
export PATH="${PWD}/clang/bin:${PWD}/gcc64/bin:${PWD}/gcc32/bin:${PATH}"

# Compile Function
compile_kernel() {
    echo "--> Starting configuration..."
    mkdir -p $OUT_DIR
    
    # Generate .config (Checking for specific vendor path)
    make -j$(nproc --all) O=$OUT_DIR ARCH=arm64 vendor/xiaomi/miatoll_defconfig || \
    make -j$(nproc --all) O=$OUT_DIR ARCH=arm64 miatoll_defconfig

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

# Packaging Function
package_kernel() {
    ZIMAGE="$OUT_DIR/arch/arm64/boot/Image.gz"
    if [ -f "$ZIMAGE" ]; then
        echo "--> Kernel compiled successfully!"
        git clone --depth=1 https://github.com/Amritorock/AnyKernel3 -b r5x AnyKernel
        cp "$ZIMAGE" AnyKernel/
        cd AnyKernel
        zip -r9 "../Stormbreaker-miatoll-${TIMESTAMP}.zip" *
        cd ..
        echo "--> Zip created: Stormbreaker-miatoll-${TIMESTAMP}.zip"
    else
        echo "--> Error: Kernel image not found!"
        exit 1
    fi
}

setup_toolchains
compile_kernel
package_kernel

