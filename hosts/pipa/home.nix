{pkgs, lib, config, inputs, ...}:
let
    pipa-pwrkey-handler = pkgs.writeShellApplication {
        name = "pipa-pwrkey-handler";
        runtimeInputs = with pkgs; [ systemd evtest ];
        text = ''
            PWRKEY_PATH="/dev/input/by-path/platform-c440000.spmi-platform-c440000.spmi:pmic@0:pon@800:pwrkey-event"
            function toggle_screen {
                busctl --user call org.gnome.ScreenSaver /org/gnome/ScreenSaver org.gnome.ScreenSaver Lock &
            }
            evtest "$PWRKEY_PATH" | while read -r line; do
                [[ "$line" =~ .*\(KEY_POWER\),\ value\ 0 ]] && toggle_screen
            done
        '';
    };
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
        settings."org/gnome/settings-daemon/plugins/power".power-button-action = "nothing";
    };
        systemd.user.services = {
            pipa-pwrkey-handler = {
                Unit.Description = "Custom power key script";
                Install.WantedBy = ["default.target"];
                Service.ExecStart = "${pipa-pwrkey-handler}/bin/pipa-pwrkey-handler";
            };
        };
}

