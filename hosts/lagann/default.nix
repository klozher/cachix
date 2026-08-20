{ config, pkgs, lib, inputs, ... }:
{
    imports = [ ./hardware.nix ];
    klozher.persist.enable = true;
    klozher.agenix.enable = true;
    klozher.desktop.enable = true;
    klozher.desktop.desktop = "hyprland";
    klozher.neovim.enable = true;

    home-manager.users.sice = import ./home.nix;
    services.displayManager.ly.enable = true;
    programs = {
        clash-verge.enable = true;
        clash-verge.tunMode = true;
        clash-verge.serviceMode = true;
    };

}

