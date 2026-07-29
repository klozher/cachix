{pkgs, lib, config, inputs, ...}:
{
    home.stateVersion = "25.11";
    home.username = "sice";
    home.homeDirectory = "/home/sice";
    home.packages = with pkgs; [
    ];
    programs.plasma = {
        enable = true;
        configFile = {
            kwinrc.Wayland."InputMethod" = {
                shellExpand = true;
                value = "/run/current-system/sw/share/applications/fcitx5-wayland-launcher.desktop";
            };
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
            (docker // { screen = 0; })
        ];
    };
    programs.firefox = {
        enable = true;
    };
}

