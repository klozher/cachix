{ config, pkgs, lib, inputs, ... }:
let
    kodi = (pkgs.kodi-gbm.withPackages (pkgs: with pkgs; [
        jellyfin
    ])).overrideAttrs {
        passthru.providedSessions = [ "kodi-gbm" ];
    };
in {
    imports = [
        ./hardware.nix
        ./containers.nix
    ];
    klozher.persist.enable = true;
    klozher.agenix.enable = true;
    klozher.neovim.enable = true;

    home-manager.users.sice = import ./home.nix;
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
    systemd.services.jellyfin-inhibitor = {
        description = "Inhibit system from idle when jellyfin playing video";
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "exec";
        serviceConfig.EnvironmentFile = config.age.secrets.jellyfin.path;
        serviceConfig.ExecStart = "${pkgs.jellyfin-inhibitor}/bin/jellyfin-inhibitor";
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

