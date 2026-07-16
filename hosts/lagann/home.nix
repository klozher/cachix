{pkgs, lib, config, inputs, ...}:
{
    home.stateVersion = "25.11";
    home.username = "sice";
    home.homeDirectory = "/home/sice";
    home.packages = with pkgs; [
    ];
    programs.firefox = {
        enable = true;
    };
}
