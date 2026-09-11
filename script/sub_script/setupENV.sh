#!/bin/bash

if [ -z $CMAKE_ ]; then
    export CMAKE_="$_CMAKE_PATH"
fi


NPROC=$(nproc)
if [ "$NPROC" -gt 16 ]; then
    NPROC=8
else
    NPROC=$(($NPROC/2))
fi
export NUMBER_OF_CORE_FOR_MAKE=$NPROC

export ROOT_DIR="$(pwd)/../../.."
export SYSC_ISLAND_MIT_PATH="$ROOT_DIR/SysC_Island_MIT"
export SCRIPT_PATH="$SYSC_ISLAND_MIT_PATH/script"
export LOG_DIR="$SCRIPT_PATH/log"

export MOUNT_APP_PATH="$SYSC_ISLAND_MIT_PATH/sw/Linux/guest"
export QEMU_PATH="$ROOT_DIR/qemu"
export HW_DTB_PATH="$SYSC_ISLAND_MIT_PATH/hw"
export QEMU_BIN_DIR="$QEMU_PATH/build"
export SYSC_QEMU_BIN_DIR="$SYSC_ISLAND_MIT_PATH/build/"
export PROJECT_UTILS_PATH="$SYSC_ISLAND_MIT_PATH/utils"

if [[ ! -d $LOG_DIR && $LOG_DIR != "" ]]; then
    mkdir $LOG_DIR
fi

cat <<EOF > $LOG_DIR/setupENV.log
##########################################################
                  Environment variable
CMAKE_                    : $CMAKE_
NUMBER_OF_CORE_FOR_MAKE   : $NUMBER_OF_CORE_FOR_MAKE
ROOT_DIR                  : $ROOT_DIR
LOG_DIR                   : $LOG_DIR
PROJECT_UTILS_PATH        : $PROJECT_UTILS_PATH
HW_DTB_PATH               : $HW_DTB_PATH
SYSC_QEMU_BIN_DIR           $SYSC_QEMU_BIN_DIR
##########################################################
EOF
