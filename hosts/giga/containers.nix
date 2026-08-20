{ config, pkgs, lib, inputs, ... }:
{
    networking.firewall = {
        trustedInterfaces = [ "Meta" "podman0" ];
        # 80 nginx
        # 2049 NFSv4
        # 8080 9090 9777 kodi
        allowedTCPPorts = [ 80 2049 8080 9090 9777 ];
        # 10000-10100 for any service require public ports
        allowedTCPPortRanges = [ { from = 10000; to = 10100; } ];
        allowedUDPPortRanges = [ { from = 10000; to = 10100; } ];
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
    systemd.services.avahi-cname = {
        description = "Avahi CNAME Publisher";
        wantedBy = [ "multi-user.target" ];
        after = [
            "network.target"
            "avahi-daemon.service"
        ];
        requires = [ "avahi-daemon.service" ];

        serviceConfig = {
            Type = "simple";
            User = "avahi";
            ExecStart = "${pkgs.go-avahi-cname}/bin/go-avahi-cname subdomain";
            Restart = "always";
            RestartSec = "10";
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
            "radarr.giga.local".locations."/".proxyPass = "http://localhost:10150";
            "sonarr.giga.local".locations."/".proxyPass = "http://localhost:10160";
            "prowlarr.giga.local".locations."/".proxyPass = "http://localhost:10170";
            "medusa.giga.local".locations."/" = {
                proxyPass = "http://localhost:10180";
                recommendedProxySettings = true;
            };
            "metacubexd.giga.local".locations."/" = {
                proxyPass = "http://localhost:10201";
                proxyWebsockets = true;
            };
        };
    };
    home-manager.sharedModules = [{
        services.podman = {
            enable = true;
            networks.media-app-net = {};
            containers = {
                jellyfin = {
                    image = "docker.io/jellyfin/jellyfin";
                    environment = {
                    };
                    ports = [ "10100:8096" ];
                    volumes = [
                        "%h/containers/jellyfin/config:/config:Z"
                        "%h/containers/jellyfin/cache:/cache:Z"
                        "/media:/media:Z"
                    ];
                };
                moviepilot = {
                    image = "docker.io/jxxghp/moviepilot-v2";
                    network = [ "media-app-net" ];
                    environment = {
                        PROXY_HOST = "socks5h://host.containers.internal:10200";
                        MOVIEPILOT_AUTO_UPDATE = "false";
                        AUTO_UPDATE_RESOURCE = "false";
                        # disable downloading image since it's often wrong language
                        FANART_ENABLE = "false";
                        #TMDB_IMAGE_DOMAIN = "localhost";
                        #TMDB_SCRAP_ORIGINAL_IMAGE = "true";
                        AUTH_SITE = "hddolby";
                        HDDOLBY_ID = "27729";
                        HDDOLBY_PASSKEY = "b6ac5096b5c203d582cb3034f2ccc4d5";
                    };
                    ports = [ "10110:3000" ];
                    volumes = [
                        "%h/containers/moviepilot/config:/config:z"
                        "%h/containers/moviepilot/cache:/moviepilot/.cache:Z"
                        "/media:/media:Z"
                    ];
                };
                pt = {
                    image = "docker.io/qbittorrentofficial/qbittorrent-nox";
                    network = [ "media-app-net" ];
                    environment = {
                        PUID = 0;
                        PGID = 0;
                        TZ = "Asia/Shanghai";
                        QBT_WEBUI_PORT = "10120";
                    };
                    ports = [
                        "10120:10120"
                        "10020:10020/tcp"
                        "10020:10020/udp"
                    ];
                    volumes = [
                        "%h/containers/pt:/config:Z"
                        "/media:/media:Z"
                    ];
                };
                bt = {
                    image = "docker.io/qbittorrentofficial/qbittorrent-nox";
                    network = [ "media-app-net" ];
                    environment = {
                        PUID = 0;
                        PGID = 0;
                        TZ = "Asia/Shanghai";
                        QBT_WEBUI_PORT = "10130";
                    };
                    ports = [
                        "10130:10130"
                        "10030:10030/tcp"
                        "10030:10030/udp"
                    ];
                    volumes = [
                        "%h/containers/bt:/config:Z"
                        "/media:/media:Z"
                    ];
                };
                peerbanhelper = {
                    image = "docker.io/ghostchu/peerbanhelper";
                    network = [ "media-app-net" ];
                    ports = [ "10140:9898" ];
                    volumes = [
                        "%h/containers/peerbanhelper/data:/app/data:Z"
                    ];
                };
                radarr = {
                    image = "lscr.io/linuxserver/radarr";
                    network = [ "media-app-net" ];
                    environment = {
                        PUID = 0;
                        PGID = 0;
                        TZ = "Asia/Shanghai";
                    };
                    ports = [ "10150:7878" ];
                    volumes = [
                        "%h/containers/radarr/config:/config:z"
                        "/media:/media:Z"
                    ];
                };
                sonarr = {
                    image = "lscr.io/linuxserver/sonarr";
                    network = [ "media-app-net" ];
                    environment = {
                        PUID = 0;
                        PGID = 0;
                        TZ = "Asia/Shanghai";
                    };
                    ports = [ "10160:8989" ];
                    volumes = [
                        "%h/containers/sonarr/config:/config:z"
                        "/media:/media:Z"
                    ];
                };
                prowlarr = {
                    image = "lscr.io/linuxserver/prowlarr";
                    network = [ "media-app-net" ];
                    environment = {
                        PUID = 0;
                        PGID = 0;
                        TZ = "Asia/Shanghai";
                    };
                    ports = [ "10170:9696" ];
                    volumes = [
                        "%h/containers/prowlarr/config:/config:z"
                        "/media:/media:Z"
                    ];
                };
                medusa = {
                    image = "docker.io/pymedusa/medusa";
                    network = [ "media-app-net" ];
                    environment = {
                        PUID = 0;
                        PGID = 0;
                        TZ = "Asia/Shanghai";
                    };
                    ports = [ "10180:8081" ];
                    volumes = [
                        "%h/containers/medusa/config:/config:z"
                        "/media:/media:Z"
                    ];
                };
            };
        };
    }];
}

