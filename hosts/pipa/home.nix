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
    umu-launcher = pkgs.callPackage ({umu-launcher, steam, buildFHSEnv, pkgs}: (
      umu-launcher.override {
        steam = steam.override {
          buildFHSEnv = buildFHSEnv.override {
            callPackage = arg1: (arg2: ((pkgs.callPackage arg1 arg2).override {
              pkgs = pkgs // { glibc_multi = pkgs.glibc; };
            }));
          };
        };
      }
    )) {};
in {
    home.stateVersion = "25.11";
    home.username = "sice";
    home.homeDirectory = "/home/sice";
    home.packages = with pkgs; [
        gamescope
        waydroid-helper
        eden
    ] ++ [
        umu-launcher
    ] ++ (with pkgs.gnomeExtensions; [
        gjs-osk
        caffeine
        screen-rotate
        app-grid-wizard
        forge
        battery-health-charging
    ]);
    home.file.".local/share/nautilus/scripts/umu-launcher" = {
        text = ''
            #!/bin/sh
            nix run ~/projects/klozher-umu#umu-launcher $1
        '';
        executable = true;
    };
    home.sessionVariables = {
        RUNTIMEPATH = "umu-steamrt4-arm64";
        PROTONPATH = "proton-cachyos";
        #PROTON_ENABLE_WAYLAND=1;
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

