{ config, pkgs, lib, inputs, ... }:
let
    kodi = (pkgs.kodi-gbm.withPackages (pkgs: with pkgs; [
        jellyfin
    ])).overrideAttrs {
        passthru.providedSessions = [ "kodi-gbm" ];
    };
    inhibitor = pkgs.writeShellApplication {
        name = "inhibitor";
        runtimeInputs = with pkgs; [ systemd ];
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
    };
in {
    imports = [
        ./hardware.nix
        ./containers.nix
    ];
    klozher.persist.enable = true;
    klozher.agenix.enable = true;
    klozher.neovim.enable = true;
    klozher.home-manager.enable = true;
    klozher.home-manager.users.sice = import ./home.nix;

    security.polkit.enable = true;
    users.users.kodi = {
        isNormalUser = true;
        home = "/var/lib/kodi";
        extraGroups = [ "video" "render" "audio" "input" ];
    };
    services.displayManager = {
        enable = true;
        ly.enable = true;
        autoLogin.user = "kodi";
        sessionPackages = [ kodi ];
        defaultSession = "kodi-gbm";
    };
    environment.systemPackages = [ kodi ];

    services.pulseaudio.enable = false;
    services.pipewire.enable = false;

    services.logind.settings.Login = {
        IdleActionSec="30m";
        IdleAction="suspend-then-hibernate";
    };
    systemd.services.custom-inhibitor = {
        description = "Inhibit system from sleep";
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "exec";
        serviceConfig.ExecStart = "${inhibitor}/bin/inhibitor";
    };

    environment.persistence."/persist" = {
        directories = [ "media/downloads" ];
    };

    services.nfs.server = {
        enable = true;
        exports = ''
            /media      192.168.1.0/24(insecure,rw,sync,no_subtree_check,crossmnt,fsid=0)
            /media/hdd0 192.168.1.0/24(insecure,rw,sync,no_subtree_check)
            /media/hdd1 192.168.1.0/24(insecure,rw,sync,no_subtree_check)
        '';
    };
    services.mihomo = {
        enable = true;
        tunMode = true;
        configFile = "/etc/mihomo/config.yaml";
        webui = pkgs.metacubexd;
    };
    services.samba = {
        enable = true;
        openFirewall = true;
        settings.global = {
            "map to guest" = "bad user";
        };
        settings.media = {
            path = "/media/hdd1/media";
            browseable = "yes";
            "read only" = "yes";
            "guest ok" = "yes";
        };
    };
}

