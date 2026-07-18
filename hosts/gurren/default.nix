{ config, pkgs, lib, inputs, ... }:
{
    imports = [ ./hardware.nix ];
    klozher.agenix.enable = true;
    klozher.desktop.enable = true;
    klozher.desktop.desktop = "plasma";
    klozher.neovim.enable = true;
    klozher.home-manager.enable = true;
    klozher.home-manager.users.sice = import ./home.nix;

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    boot.kernelModules = ["ntsync"];
    virtualisation.libvirtd.enable = true;
    programs = {
        steam = {
            enable = true;
            extraPackages = with pkgs; [ gamescope mangohud ];
            extraCompatPackages = with pkgs; [ proton-ge-bin ];
        };
        clash-verge.enable = true;
        clash-verge.tunMode = true;
        clash-verge.serviceMode = true;
        virt-manager.enable = true;
    };
    networking.firewall = {
        enable = false;
        allowedTCPPorts = [ 3389 10030 ];
        allowedUDPPorts = [ 3389 10030 ];
    };
    services.scx.enable = true;
    services.scx.scheduler = "scx_lavd";

    services.wivrn = {
        enable = true;
        package = (pkgs.wivrn.override { cudaSupport = true; });
        openFirewall = true;
        steam.importOXRRuntimes = true;
        highPriority = true;
    };
    services.samba = {
        enable = true;
        openFirewall = true;
        usershares.enable = true;
    };
    #programs.cdemu.enable = true;
}

