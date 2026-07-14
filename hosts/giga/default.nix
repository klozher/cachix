{ config, pkgs, lib, inputs, ... }:
let
    kodi = pkgs.kodi-gbm.withPackages (pkgs: with pkgs; [
        jellyfin
    ]);
    inhibitor = pkgs.writeShellApplication {
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
    };
in {
    imports = [ ./hardware.nix ];
    klozher.agenix.enable = true;
    klozher.neovim.enable = true;
    klozher.home-manager.enable = true;
    klozher.home-manager.users.sice = import ./home.nix;

    users.users.kodi = {
        isNormalUser = true;
        home = "/var/lib/kodi";
        extraGroups = [ "video" "render" "audio" "input" ];
    };
    services.getty.autologinUser = "kodi";
    services.greetd = {
        enable = true;
        settings.initial_session = {
            command = "${kodi}/bin/kodi-standalone";
            user = "kodi";
        };
        settings.default_session = {
            command = "${kodi}/bin/kodi-standalone";
            user = "kodi";
        };
    };

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
    services.mihomo = {
        enable = true;
        tunMode = true;
        configFile = "/etc/mihomo/config.yaml";
        webui = pkgs.metacubexd;
    };
    virtualisation.containers = {
        enable = true;
        containersConf.settings.engine.env = [
            "http_proxy=http://127.0.0.1:10200"
            "https_proxy=http://127.0.0.1:10200"
            "no_proxy=localhost,127.0.0.1,*.local"
        ];
    };
    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers = {
        jellyfin = {
            image = "docker.io/jellyfin/jellyfin";
            user = toString config.users.users.sice.uid;
            environment = {
                http_proxy = "http://host.containers.internal:10200";
                https_proxy = "http://host.containers.internal:10200";
            };
            ports = [ "10100:8096" ];
            volumes = [
                "/home/sice/containers/jellyfin/config:/config:Z"
                "/home/sice/containers/jellyfin/cache:/cache:Z"
                "/media:/media:Z"
            ];
        };
        moviepilot = {
            image = "docker.io/jxxghp/moviepilot-v2";
            environment = {
                PUID = toString config.users.users.sice.uid;
                PGID = toString config.users.groups.users.gid;
                PROXY_HOST = "socks5h://host.containers.internal:10200";
                MOVIEPILOT_AUTO_UPDATE = "false";
                AUTO_UPDATE_RESOURCE = "false";
                TMDB_SCRAP_ORIGINAL_IMAGE = "true";
                AUTH_SITE = "hddolby";
                HDDOLBY_ID = "27729";
                HDDOLBY_PASSKEY = "b6ac5096b5c203d582cb3034f2ccc4d5";
            };
            ports = [ "10110:3000" ];
            volumes = [
                "/home/sice/containers/moviepilot/config:/config:z"
                "/home/sice/containers/moviepilot/cache:/moviepilot/.cache:Z"
                "/media:/media:Z"
            ];
        };
        pt = {
            image = "docker.io/qbittorrentofficial/qbittorrent-nox";
            environment = {
                PUID = toString config.users.users.sice.uid;
                PGID = toString config.users.groups.users.gid;
                TZ = "Asia/Shanghai";
                QBT_WEBUI_PORT = "10120";
            };
            ports = [
                "10120:10120"
                "10020:10020/tcp"
                "10020:10020/udp"
            ];
            volumes = [
                "/home/sice/containers/pt:/config:Z"
                "/media:/media:Z"
            ];
        };
        bt = {
            image = "docker.io/qbittorrentofficial/qbittorrent-nox";
            environment = {
                PUID = toString config.users.users.sice.uid;
                PGID = toString config.users.groups.users.gid;
                TZ = "Asia/Shanghai";
                QBT_WEBUI_PORT = "10130";
            };
            ports = [
                "10130:10130"
                "10030:10030/tcp"
                "10030:10030/udp"
            ];
            volumes = [
                "/home/sice/containers/bt:/config:Z"
                "/media:/media:Z"
            ];
        };
        peerbanhelper = {
            image = "docker.io/ghostchu/peerbanhelper";
            user = toString config.users.users.sice.uid;
            ports = [ "10140:9898" ];
            volumes = [
                "/home/sice/containers/peerbanhelper/data:/app/data:Z"
            ];
        };
        go-avahi-cname = {
            image = "ghcr.io/grishy/go-avahi-cname";
            cmd = [ "subdomain" ];
            extraOptions = [ "--network=host" ];
            volumes = [
                "/var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket"
            ];
        };
    };
    services.resolved.settings.Resolve.MulticastDNS = "resolve";
    services.avahi = {
        enable = true;
        openFirewall = true;
        publish = {
            enable = true;
            userServices = true;
            domain = true;
            addresses = true;
        };
    };
    services.nginx = {
        enable = true;
        virtualHosts = {
            "_".locations."/".return = "444";
            "jellyfin.giga.local".locations."/" = {
                proxyPass = "http://localhost:10100";
                proxyWebsockets = true;
            };
            "moviepilot.giga.local".locations."/".proxyPass = "http://localhost:10110";
            "pt.giga.local".locations."/".proxyPass = "http://localhost:10120";
            "bt.giga.local".locations."/".proxyPass = "http://localhost:10130";
            "peerbanhelper.giga.local".locations."/".proxyPass = "http://localhost:10140";
            "metacubexd.giga.local".locations."/" = {
                proxyPass = "http://localhost:10201";
                proxyWebsockets = true;
            };
        };
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
    networking.firewall = {
        enable = false;
        trustedInterfaces = [ "Meta" ];
        # 80 nginx
        # 8080 9090 9777 kodi
        allowedTCPPorts = [ 80 8080 9090 9777 ];
        # 10000-10100 for any service require public ports
        allowedTCPPortRanges = [ { from = 10000; to = 10100; } ];
        allowedUDPPortRanges = [ { from = 10000; to = 10100; } ];
    };
}
