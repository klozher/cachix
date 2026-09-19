{writeShellApplication, coreutils, systemd, curl, jq, gnugrep}:
writeShellApplication {
    name = "custom-inhibitor";
    runtimeInputs = [ coreutils systemd curl jq gnugrep ];
    text = ''
        WAIT_TIME=30

        function is_jellyfin_busy {
            curl -sH "Authorization: MediaBrowser Token=$JELLYFIN_TOKEN" "$JELLYFIN_HOST/Sessions" \
            | jq -c '.[] | [has("NowPlayingItem"), .PlayState.IsPaused]' \
            | grep -Fqs '[true,false]'
        }

        function is_qbittorrent_busy {
            local HOSTS KEYS
            read -r -a HOSTS <<< "$QBITTORRENT_HOSTS"
            read -r -a KEYS <<< "$QBITTORRENT_KEYS"
            for i in "''${!HOSTS[@]}"; do
                [[ "$(curl -s -H "Authorization: Bearer ''${KEYS[i]}" "''${HOSTS[i]%/}/api/v2/torrents/info?filter=downloading" | jq -e 'length > 0')" == "true" ]] && return 0
            done
            return 1
        }

        function is_busy {
            is_jellyfin_busy || is_qbittorrent_busy
        }

        INHIBITOR_PID=0
        function hold_inhibitor {
            if [[ $INHIBITOR_PID == 0 ]]; then
                systemd-inhibit --mode=block --what=idle --why="custom inhibitor" sleep infinity &
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
            if is_busy; then
                IDLE_TIME=0
                hold_inhibitor
            else
                IDLE_TIME=$((IDLE_TIME+1))
            fi
            if (( IDLE_TIME > WAIT_TIME )); then
                release_inhibitor
            fi
            sleep 1m;
        done
        '';
}

