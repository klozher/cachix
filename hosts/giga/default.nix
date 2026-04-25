{ config, pkgs, lib, inputs, ... }:
{
    networking.hostName = "giga";
    users.users.kodi = {
      extraGroups = [
        # allow kodi access to keyboards
        "input"
      ];
      isNormalUser = true;
    };
    services.logind.settings.Login = {
        IdleActionSec="30m";
        IdleAction="suspend-then-hibernate";
    };
    systemd.services.custom-inhibitor = {
        description = "Inhibit system from sleep";
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "exec";
        serviceConfig.ExecStart = (
            let inhibitor = pkgs.writeShellApplication {
                name = "inhibitor";
                text = ''
                    while true; do
                        busy=false;
                        # test nfs client
                        NFS_CLIENT="/proc/fs/nfsd/clients/";
                        if [ -d "$NFS_CLIENT" ]; then
                            if [ -n "$(find "$NFS_CLIENT" -mindepth 1)" ]; then
                                busy=true;
                            fi
                        fi
                        # mark session busy
                        if [ "$busy" = "true" ]; then
                            touch /dev/tty1;
                        fi
                        sleep 1m;
                    done
                '';
            }; in "${inhibitor}/bin/inhibitor");
    };
    services.pulseaudio.enable = false;
    services.pipewire.enable = false;
    services.getty.autologinUser = "kodi";
    services.greetd = {
      enable = true;
      settings = {
        initial_session = let
          kodi = pkgs.kodi-gbm.withPackages (pkgs: with pkgs; [
            jellyfin
          ]);
        in {
          command = "${kodi}/bin/kodi-standalone";
          user = "kodi";
        };
        default_session = {
          command = "${pkgs.greetd}/bin/agreety --cmd sway";
      };
      };
    };

    programs = {
    };

    environment.systemPackages = with pkgs; [
    ];
}
