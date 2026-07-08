{config, lib, osConfig, ...}:
let
    desktop = osConfig.klozher.desktop;
in {
    config = {
        programs.zsh = {
            enable = true;
            dotDir = "${config.xdg.configHome}/zsh";
            prezto = {
                enable = true;
                editor.keymap = "vi";
                editor.promptContext = true;
                utility.safeOps = true;
                prompt.theme = "agnoster";
            };
        };
        programs.mangohud = lib.mkIf desktop.enable {
            enable = true;
            settings = {};
        };
    };
}

