#!/bin/bash

pushd sub_script > /dev/null

# Export env variable
source ./setupENV.sh

popd > /dev/null


_packages="default"
_exit_code=0    # 0 pass, 1 fail, 2 warning(allow failture), other = fail

export TERMINAL_ID=$(od -An -N2 -i /dev/urandom | tr -dc '0-9' | head -c 5)
_term_id=${TERMINAL_ID}



# Clean tail process is hang
cleanup() {
    echo "Cleaning up..."
    pkill -f "tail -F $LOG_DIR"
}

# Set trap to clean tail after using 
trap cleanup SIGINT SIGTERM SIGHUP EXIT




# Execute single 
function execute_single() {

    pushd $SYSC_ISLAND_MIT_PATH/script/sub_script/ > /dev/null
    source ./config.sh

    echo
    echo " # Remove the backend file of account ${USER} "
    echo

    for file in /dev/shm/*"$USER"*.img; do
        if [ -f "$file" ]; then
            echo " # Removing $file"
            rm -f "$file"
        fi
    done



    args=("./execute_vp.sh |& tee $LOG_DIR/excute_vp.log")
    args+=("./start_qemu.sh |& tee $LOG_DIR/boot.log")

    tmux_split_run "${args[@]}"

    popd > /dev/null
}

tmux_split_run() {
    local safe_user="${USER//[^a-zA-Z0-9_]/_}"
    local session="${safe_user}_session"
    local cmds=("$@")

    tmux new-session -d -s "$session" \; set -g mouse on 

    # Pane 0 = CA
    tmux select-pane -t "$session":0.0 -T "${session}:cortex-a"
    tmux send-keys -t "$session":0.0 "# Welcome to Cortex-A Terminal" C-m
    tmux send-keys -t "$session":0.0 "source ./config.sh" C-m
    tmux send-keys -t "$session":0.0 "${cmds[0]}" C-m

    local first_pane=$(tmux list-panes -t "$session":0 -F "#{pane_id}" | head -n 1)
    # Start a background process to monitor the first pane
        (
            while true; do
                # Check if the first pane still exists
                if ! tmux list-panes -t "$session":0 -F "#{pane_id}" | grep -q "$first_pane"; then
                    tmux kill-session -t "$session"
                    exit 0
                fi
                sleep 1
            done
        ) &

    # Only CA → all additional cmds also run as CA
    for i in "${!cmds[@]}"; do
        [ "$i" -eq 0 ] && continue
        tmux split-window -h -t "$session":0
        tmux select-layout -t "$session":0 tiled
        tmux select-pane -t "$session":0.$i -T "${session}:cortex-a"
        tmux send-keys -t "$session":0.$i "source ./config.sh" C-m
        tmux send-keys -t "$session":0.$i "${cmds[$i]}" C-m
    done

    tmux attach-session -t "$session"
}

echo " ===================== Executing ====================="

execute_single

exit $_exit_code
