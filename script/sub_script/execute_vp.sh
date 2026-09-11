#!/bin/bash

echo " ======== Execute SysC_Island_MIT Package ========"

mkdir -p "$SIM_QEMU_PORT_PATH/virt/"


pushd $SYSC_ISLAND_MIT_PATH/ > /dev/null
    start_time=$(date +%s)
    $SYSC_QEMU_BIN_DIR/vp --luafile_with_sysc_island_mit conf_with_sysc_island_mit.lua
    EXIT_CODE=$?

    # Handle the timeout exit code
    if [ $EXIT_CODE -eq 124 ]; then
        echo "[execute.sh ERROR] Command timed out after 30 minutes."
    elif [ $EXIT_CODE -ne 0 ]; then
        echo "[execute.sh ERROR] Command failed with exit code $EXIT_CODE."
    else
        echo "Command executed successfully."
    fi
    end_time=$(date +%s)
    elapsed_time=$(echo "$end_time - $start_time" | bc)
    echo " ======== Execute App Done. Execute time: $elapsed_time s ========"
popd > /dev/null
