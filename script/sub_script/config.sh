#!/bin/bash
# User modification - Modify env variables if needed

# -----------------------------------------------------------
# --------------- Start SW Configurations--------------------
# -----------------------------------------------------------

### ----- Linux configuration -----
export PARENT_DIR="$(pwd)/../.."

export HW_DTB_PATH="$PARENT_DIR/hw"

export SW_LINUX_GUEST_PATH="$PARENT_DIR/sw/Linux/guest"
export SW_LINUX_IMAGE_PATH="$PARENT_DIR/sw/Linux/Image"
export SW_LINUX_ROOTFS_PATH="$PARENT_DIR/sw/Linux/rootfs.ext4"
export SW_LINUX_DTB_PATH="$PARENT_DIR/sw/Linux/"




export SW_LINUX_USER_DTB_PATH="$PARENT_DIR/sw/Linux/arm64-virt-guest.dtb"


# -----------------------------------------------------------
# --------------- End SW Configurations----------------------
# -----------------------------------------------------------

# -----------------------------------------------------------
# --------------- Start Simulator Configurations-------------
# -----------------------------------------------------------

### ----- QEMU configuration -----
export SIM_QEMU_PORT_PATH="/tmp/qemu-rport-$USER"

### ----- UART configuration -----
## The supported options: pl011.
export SIM_UART_RCAR_AARCH64="pl011"


# -----------------------------------------------------------
# --------------- End Simulator Configurations---------------
# -----------------------------------------------------------


