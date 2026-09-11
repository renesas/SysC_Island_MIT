#!/bin/bash
source colors.sh

find_free_port() {
  for port in {10026..10100}; do
    if ! netstat -an | grep -q ":$port"; then
      echo $port
      return
    fi
  done
  echo "No host port free found!" >&2
  exit 1
}
machine_option="-M arm-generic-fdt"
PORT=$(find_free_port)

DT_NAME="arm64-virt-guest"
DT_NAME_HW="arm64-virt-hw"

# Compiling of Device Tree(dts -> dtb)
    mprint "$BRIGHT_BLUE" "========== Compiling Device Tree(SW): " "$BRIGHT_MAGENTA" "$DT_NAME.dts" "$BRIGHT_BLUE" " =========="
    if dtc -q -I dts -O dtb -o "$SW_LINUX_DTB_PATH/$DT_NAME.dtb" "$SW_LINUX_DTB_PATH/$DT_NAME.dts"; then
        print_success "SUCCESS: Device tree compiled successfully - $DT_NAME.dtb created"
    else
        print_error "ERROR: Device tree compilation failed for $DT_NAME.dts" >&2
        exit 1
    fi

    # Compiling of Device Tree(dts -> dtb) at HW side
    mprint "$BRIGHT_BLUE" "========== Compiling Device Tree(HW): " "$BRIGHT_MAGENTA" "$DT_NAME_HW.dts" "$BRIGHT_BLUE" " =========="
    if dtc -q -I dts -O dtb -o "$HW_DTB_PATH/$DT_NAME_HW.dtb" "$HW_DTB_PATH/$DT_NAME_HW.dts"; then
        print_success "SUCCESS: Device tree compiled successfully - $DT_NAME_HW.dtb created"
    else
        print_error "ERROR: Device tree compilation failed for $DT_NAME_HW.dts" >&2
        exit 1
    fi

$QEMU_PATH/build/qemu-system-aarch64 \
    $machine_option \
    -kernel $SW_LINUX_IMAGE_PATH\
    -append "earlycon=pl011,0x3C000000 console=ttyAMA0,115200 root=/dev/vda rw rootwait debug loglevel=8 ignore_loglevel cma=560M iommu.passthrough=1" \
    -drive if=none,id=rootfs,format=raw,file=$SW_LINUX_ROOTFS_PATH\
    -device virtio-blk-device,drive=rootfs \
    -netdev user,id=net0,hostfwd=tcp::$PORT-:22 \
    -object memory-backend-file,id=mem0,mem-path=/dev/shm/dram_mirror00_$USER.img,size=2G,share=on \
    -object memory-backend-file,id=mem1,mem-path=/dev/shm/shared_mem_00_$USER.img,size=0x80000,share=on \
    -nographic \
    -fsdev local,id=myfs,path=$SW_LINUX_GUEST_PATH,security_model=mapped-xattr \
    -machine hw-dtb=$HW_DTB_PATH/$DT_NAME_HW.dtb \
    -chardev socket,id=pl-rp,path=$SIM_QEMU_PORT_PATH/virt/qemu-rport-_cosim@0 \
    -global remote-port.sync-quantum=10000 \
    -rtc clock=vm \
    -m 2G,maxmem=16G \
    -dtb $SW_LINUX_USER_DTB_PATH \
    $extra_option  2>&1 | tee ~/qemu_rfs.log

rm -rf $SIM_QEMU_PORT_PATH
