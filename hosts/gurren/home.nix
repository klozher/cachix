{pkgs, lib, config, inputs, ...}:
{
    home.stateVersion = "25.11";
    home.username = "sice";
    home.homeDirectory = "/home/sice";
    home.packages = with pkgs; [
        heroic
        umu-launcher

        mpv
        jellyfin-mpv-shim

        qbittorrent

        wpsoffice-cn
        anki-bin

        unrar
    ] ++ (with pkgs.kdePackages; [
        yakuake
    ]);
    home.sessionVariables = {
        QT_IM_MODULE="fcitx";
        MOZ_DISABLE_RDD_SANDBOX = "1";
        PROTONPATH = "GE-Latest";
        PROTON_ENABLE_WAYLAND=1;
        PROTON_ENABLE_HDR=1;
        PROTON_ENABLE_NVAPI=1;
        #ANKI_WAYLAND=1;

    };
    xdg.autostart = {
        enable = true;
        entries = map (name: "${config.home.profileDirectory}/share/applications/" + name + ".desktop") [
            "org.kde.yakuake"
            "jellyfin-mpv-shim"
        ];
    };
    programs.plasma = {
        enable = true;
        configFile = {
            kwinrc.Wayland."InputMethod" = {
                shellExpand = true;
                value = "/run/current-system/sw/share/applications/fcitx5-wayland-launcher.desktop";
            };
            kwinrc.Windows_HDR.MaxFrameAverage = 0;
            kwinrc.Windows_HDR.MaxLuminance = 1005;
            kwinrc.Windows_HDR.Reference = 200;
            #kdeglobals.KDE.AutomaticLookAndFeel = true;
            dolphinrc.DetailsMode.PreviewSize = 22;
        };
        panels = let
            topbar = {
                location = "top";
                alignment = "center";
                floating = false;
                height = 40;
                hiding = "dodgewindows";
                lengthMode = "fill";
                widgets = [{
                    applicationTitleBar = {
                        layout.elements = [ "windowIcon" "windowTitle" ];
                        windowTitle.source = "appName";
                    };
                } {
                    appMenu = {};
                } {
                    panelSpacer = {
                        expanding = true;
                    };
                } {
                    systemTray = {};
                } {
                    pager = {};
                } {
                    digitalClock = {};
                } {
                    applicationTitleBar = {
                        layout.elements = [ "windowMinimizeButton" "windowMaximizeButton" "windowCloseButton" ];
                    };
                }];
            };
            docker = {
                location = "bottom";
                alignment = "center";
                floating = true;
                height = 72;
                hiding = "dodgewindows";
                lengthMode = "fit";
                widgets = [{
                    kickoff = {};
                } {
                    iconTasks = {
                        behavior.showTasks = {
                            onlyInCurrentScreen = true;
                            onlyInCurrentDesktop = true;
                            onlyInCurrentActivity = true;
                        };
                    };
                }];
            };
        in [
            (topbar // { screen = 0; })
            (topbar // { screen = 1; })
            (docker // { screen = 0; })
            (docker // { screen = 1; })
        ];
        startup = {
            desktopScript."panels".preCommands = lib.mkForce ''
                sleep 3
                [ -f ${config.xdg.configHome}/plasma-org.kde.plasma.desktop-appletsrc ] && rm ${config.xdg.configHome}/plasma-org.kde.plasma.desktop-appletsrc
            '';
        };
    };
    programs.firefox = {
        enable = true;
        profiles.test = {
            id = 0;
            settings = {
                "media.av1.enabled" = false;
                "media.hardware-video-decoding.force-enabled" = true;
                "sidebar.verticalTabs" = true;
                "media.rdd-ffmpeg.enabled" = true;
            };
        };
    };
    programs.aria2 = {
        enable = true;
        settings = {
        };
    };
    programs.mangohud = {
        enable = true;
        enableSessionWide = true;
        settings = {};
    };
    programs.anki = {
        enable = false;
    };
    programs.vscode = {
        enable = true;
    };
}
