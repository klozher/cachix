{ config, pkgs, lib, inputs, ... }:
{
    imports = [ ./hardware.nix ];
    klozher.agenix.enable = true;
    klozher.desktop.enable = true;
    klozher.desktop.desktop = "tile";
    klozher.neovim.enable = true;
    klozher.home-manager.enable = true;
    klozher.home-manager.users.sice = import ./home.nix;

    services.displayManager.ly.enable = true;
    programs = {
        clash-verge.enable = true;
        clash-verge.tunMode = true;
        clash-verge.serviceMode = true;
    };

}

