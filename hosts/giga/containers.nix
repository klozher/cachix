{ config, pkgs, lib, inputs, ... }:
let
    containers = {
        jellyfin = {
            image = "docker.io/jellyfin/jellyfin";
            web = {
                hostPort = "10100";
                containerPort = "8096";
            };
            environment = {
                HTTP_PROXY="http://host.containers.internal:10200";
                HTTPS_PROXY="http://host.containers.internal:10200";
                NO_PROXY="localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,169.254.1.2/24,host.containers.internal";
            };
            volumes = [
                "%h/containers/jellyfin/config:/config:Z"
                "%h/containers/jellyfin/cache:/cache:Z"
            ];
        };
        moviepilot = {
            image = "docker.io/jxxghp/moviepilot-v3";
            web = {
                hostPort = "10110";
                containerPort = "3000";
            };
            environment = {
            };
            volumes = [
                "%h/containers/moviepilot/config:/config:z"
                "%h/containers/moviepilot/cache:/moviepilot/.cache:Z"
            ];
        };
        pt = {
            image = "docker.io/qbittorrentofficial/qbittorrent-nox";
            web = {
                hostPort = "10120";
            };
            environment = {
                QBT_WEBUI_PORT = "80";
            };
            ports = [
                "10020:10020/tcp"
                "10020:10020/udp"
            ];
            volumes = [
                "%h/containers/pt:/config:Z"
            ];
        };
        bt = {
            image = "docker.io/qbittorrentofficial/qbittorrent-nox";
            web = {
                hostPort = "10130";
            };
            environment = {
                QBT_WEBUI_PORT = "80";
            };
            ports = [
                "10030:10030/tcp"
                "10030:10030/udp"
            ];
            volumes = [
                "%h/containers/bt:/config:Z"
            ];
        };
        peerbanhelper = {
            image = "docker.io/ghostchu/peerbanhelper";
            web = {
                hostPort = "10140";
                containerPort = "9898";
            };
            volumes = [
                "%h/containers/peerbanhelper/data:/app/data:Z"
            ];
        };
        radarr = {
            image = "lscr.io/linuxserver/radarr";
            web = {
                hostPort = "10150";
                containerPort = "7878";
            };
            volumes = [
                "%h/containers/radarr/config:/config:z"
            ];
        };
        sonarr = {
            image = "lscr.io/linuxserver/sonarr";
            web = {
                hostPort = "10160";
                containerPort = "8989";
            };
            volumes = [
                "%h/containers/sonarr/config:/config:z"
                "/media:/media:Z"
            ];
        };
        prowlarr = {
            image = "lscr.io/linuxserver/prowlarr";
            web = {
                hostPort = "10170";
                containerPort = "9696";
            };
            volumes = [
                "%h/containers/prowlarr/config:/config:z"
            ];
        };
        medusa = {
            image = "docker.io/pymedusa/medusa";
            web = {
                hostPort = "10180";
                containerPort = "8081";
            };
            volumes = [
                "%h/containers/medusa/config:/config:z"
            ];
        };
    };
in {
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
        virtualHosts = (lib.mapAttrs' (name: cfg: lib.nameValuePair "${name}.giga.local" {
            locations."/" = {
                proxyPass = "http://localhost:${cfg.web.hostPort}";
                recommendedProxySettings = true;
                proxyWebsockets = true;
            };
        }) containers) // {
            "metacubexd.giga.local".locations."/" = {
                proxyPass = "http://localhost:10201";
                proxyWebsockets = true;
            };
            "_".locations."/".return = "444";
        };
    };
    home-manager.users.sice = {
        services.podman = {
            enable = true;
            networks.media-app-net = {};
            containers = lib.mapAttrs (name: cfg: {
                inherit (cfg) image;
                network = [ "media-app-net:--map-gw" ];
                volumes = (cfg.volumes or []) ++ [ "/media:/media:Z" ];
                ports = (cfg.ports or [])
                    ++ (if builtins.hasAttr "web" cfg
                        then [ "${cfg.web.hostPort}:${cfg.web.containerPort or "80"}" ]
                        else []);
                environment = (cfg.environment or {}) // {
                    PUID = 0;
                    PGID = 0;
                    TZ = "Asia/Shanghai";
                };
            }) containers;
        };
    };
}

