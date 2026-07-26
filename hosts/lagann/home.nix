{pkgs, lib, config, inputs, ...}:
{
    home.username = "sice";
    home.homeDirectory = "/home/sice";
    home.packages = with pkgs; [
    ];
    programs.firefox = {
        enable = true;
    };
    programs.aider-chat.enable = true;
}
