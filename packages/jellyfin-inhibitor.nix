{writeShellApplication, coreutils, systemd, curl, jq, gnugrep}:
writeShellApplication {
    name = "jellyfin-inhibitor";
    runtimeInputs = [ coreutils systemd curl jq gnugrep ];
    text = ''
        WAIT_TIME=30

        function is_busy {
            curl -sH "Authorization: MediaBrowser Token=$JELLYFIN_TOKEN" "$JELLYFIN_URL" \
            | jq -c '.[] | [has("NowPlayingItem"), .PlayState.IsPaused]' \
            | grep -Fqs '[true,false]'
        }

        INHIBITOR_PID=0
        function hold_inhibitor {
            if [[ $INHIBITOR_PID == 0 ]]; then
                systemd-inhibit --what=sleep --why="jellyfin inhibitor" sleep infinity &
                INHIBITOR_PID=$!
            fi
        }

        function release_inhibitor {
            if [[ $INHIBITOR_PID != 0 ]]; then
                kill $INHIBITOR_PID
                INHIBITOR_PID=0
            fi
        }

        IDLE_TIME=0
        while true; do
            sleep 1m;
            if is_busy; then
                IDLE_TIME=0
                hold_inhibitor
            else
                IDLE_TIME=$((IDLE_TIME+1))
            fi
            if (( IDLE_TIME > WAIT_TIME )); then
                release_inhibitor
            fi
        done
        '';
}

