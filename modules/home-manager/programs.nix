{config, lib, osConfig, ...}:
let
    desktop = osConfig.klozher.desktop;
in {
    config = {
        programs.mangohud = lib.mkIf desktop.enable {
            enable = true;
            settings = {};
        };
    };
}

