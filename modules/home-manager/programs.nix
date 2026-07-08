{config, lib, osConfig, ...}:
let
    desktop = osConfig.klozher.desktop;
in {
    config = {
        programs.zsh = {
            enable = true;
            dotDir = "${config.xdg.configHome}/zsh";
        };
        programs.mangohud = lib.mkIf desktop.enable {
            enable = true;
            settings = {};
        };
    };
}

