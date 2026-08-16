{ config, pkgs, lib, inputs, ... }:
{
    users.defaultUserShell = pkgs.zsh;
    programs.zsh = {
        enable = true;
        histSize = 10000;
        enableCompletion = true;
        enableBashCompletion = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
    };
    home-manager.sharedModules = [({config, ...}: {
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
            shellAliases = {
                "wake-giga" = "${pkgs.wakeonlan}/bin/wakeonlan 74:d4:35:89:f3:fb";
                "env-zhipu" = "env $(< ${config.age.secrets.zhipu.path})";
                "aider" = "${pkgs.aider-chat}/bin/aider --config ${config.xdg.configHome}/aider/config.yml";
                "aider-zhipu" = "env-zhipu aider";
                "claude-zhipu" = "env-zhipu claude";
            };
        };
    })];
}

