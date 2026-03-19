#!/bin/bash
# Kernel build script for Miatoll - Fixed Configuration Logic

set -e
set -o pipefail

# --- Configuration ---
export ARCH=arm64
export KBUILD_BUILD_HOST=GitHub-Actions
export KBUILD_BUILD_USER="Hamza8702"
TIMESTAMP=$(date +"%Y%m%d-%H")
OUT_DIR="out"

# --- Setup Toolchains ---
setup_toolchains() {
    echo "--> Cloning toolchains..."
    # Clones only if directory doesn't exist to save time
    [ ! -d "clang" ] && git clone --depth=1 https://github.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-6443078 clang
    [ ! -d "gcc64" ] && git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 gcc64
    [ ! -d "gcc32" ] && git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 gcc32
}

# Export Toolchain Paths
export PATH="${PWD}/clang/bin:${PWD}/gcc64/bin:${PWD}/gcc32/bin:${PATH}"

# --- Kernel Compilation ---
compile_kernel() {
    echo "--> Starting configuration..."
    mkdir -p $OUT_DIR
    
    # Step 1: Generate the base defconfig first
    echo "--> Generating base miatoll_defconfig..."
    make -j$(nproc --all) O=$OUT_DIR ARCH=arm64 miatoll_defconfig

    # Step 2: Merge your custom config fragment if it exists
    # This prevents the "base file .config does not exist" error
    if [ -f "arch/arm64/configs/vendor/xiaomi/miatoll.config" ]; then
        echo "--> Merging custom vendor/xiaomi/miatoll.config..."
        cat arch/arm64/configs/vendor/xiaomi/miatoll.config >> $OUT_DIR/.config
        # Process the newly merged config
        make -j$(nproc --all) O=$OUT_DIR ARCH=arm64 oldconfig
    fi

    # Step 3: Start the actual compilation
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

# --- Packaging ---
package_kernel() {
    echo "--> Locating build output..."
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
        echo "--> Package created: Stormbreaker-miatoll-${TIMESTAMP}.zip"
    else
        echo "--> Error: Kernel image (Image/Image.gz) not found!"
        exit 1
    fi
}

# --- Execution Flow ---
setup_toolchains
compile_kernel
package_kernel
