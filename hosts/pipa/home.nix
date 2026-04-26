{pkgs, lib, config, inputs, ...}:
let
in {
    home.stateVersion = "25.11";
    home.username = "sice";
    home.homeDirectory = "/home/sice";
    home.packages = with pkgs; [
        gamescope
    ] ++ (with pkgs.gnomeExtensions; [
        gjs-osk
        caffeine
        screen-rotate
        app-grid-wizard
        forge
        battery-health-charging
    ]);
    home.sessionVariables = {
        RUNTIMEPATH = "umu-steamrt4-arm64";
        PROTONPATH = "proton-cachyos";
        PROTON_ENABLE_WAYLAND=1;
    };
    dconf = {
        enable = true;
        settings."org/gnome/shell".enabled-extensions = with pkgs.gnomeExtensions; [
          screen-rotate.extensionUuid
          gsconnect.extensionUuid
          gjs-osk.extensionUuid
        ];
    };
}

