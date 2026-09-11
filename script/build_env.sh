#!/bin/bash

set -e

start_time_total=$(date +%s)
echo " ======== Start Build  ========"

pushd sub_script > /dev/null

# Export environment variables
source ./setupENV.sh

# Default number of cores for parallel build
NUMBER_OF_CORE_FOR_MAKE="${NUMBER_OF_CORE_FOR_MAKE:-8}"

# Default build QEMU flag
BUILD_QEMU="${BUILD_QEMU:-1}"

# Log directories
LOG_DIR="${ROOT_DIR}/log"
mkdir -p "$LOG_DIR"


########################################
# 1. Build SYSC_ISLAND_MIT_PATH
########################################
echo " ======== Build SYSC_ISLAND_MIT_PATH ========"

SYSC_LOG="${LOG_DIR}/build_SYSC_ISLAND_MIT.log"
mkdir -p "$SYSC_ISLAND_MIT_PATH/build"

pushd "$SYSC_ISLAND_MIT_PATH" > /dev/null

cmake -H. -G "Unix Makefiles" -B build \
      -DCMAKE_CXX_STANDARD=17 \
      -DCMAKE_BUILD_TYPE=Release \

cmake --build build --target all --parallel "$NUMBER_OF_CORE_FOR_MAKE" 2>&1 | tee "$SYSC_LOG"


########################################
# 2. Build QEMU
########################################
if [ "$BUILD_QEMU" -eq 1 ]; then
    echo " ======== Build QEMU ========"


    QEMU_BUILD_DIR="${QEMU_PATH}/build"
    QEMU_LOG="${LOG_DIR}/buildQEMU.log"
    QEMU_PATCHES="${SCRIPT_PATH}/qemu-patches.tar.gz"
    PATCH_DIR=$(mktemp -d -t qemu-patches-XXXXXX)

    trap 'rm -rf "$PATCH_DIR"' EXIT

    pushd "$QEMU_PATH" > /dev/null

    tar -xzf "$QEMU_PATCHES" -C "$PATCH_DIR"
    git am "$PATCH_DIR"/qemu-patches/*.patch

    mkdir -p "$QEMU_BUILD_DIR"

    pushd "$QEMU_BUILD_DIR" > /dev/null

    "$QEMU_PATH/configure" \
        --target-list=aarch64-softmmu \
        --enable-fdt \
        --enable-slirp \
        --enable-sdl \
        --enable-gtk \
        --enable-virglrenderer \
        --enable-opengl \
        --disable-kvm \
        --disable-xen \

    make -j "$NUMBER_OF_CORE_FOR_MAKE" 2>&1 | tee "$QEMU_LOG"

    popd > /dev/null

    echo " ======== QEMU build finished. Logs at $QEMU_LOG ========"
else
    echo " ======== QEMU build skipped ========"
fi

########################################
# Done
########################################
end_time_total=$(date +%s)
elapsed_total=$(echo "$end_time_total - $start_time_total" | bc)

echo " ======== Build ENV successfully. Total build time: $elapsed_total s ========"

popd > /dev/null
