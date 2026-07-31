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
        };
    })];
}

