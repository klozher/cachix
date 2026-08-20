{ config, pkgs, lib, inputs, ... }:
{
    imports = [
        ./hardware.nix
        inputs.nixpkgs-xr.nixosModules.nixpkgs-xr
    ];
    klozher.persist.enable = true;
    klozher.agenix.enable = true;
    klozher.desktop.enable = true;
    klozher.desktop.desktop = "plasma";
    klozher.neovim.enable = true;

    home-manager.users.sice = import ./home.nix;
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    boot.kernelModules = ["ntsync"];
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
    services.scx.enable = true;
    services.scx.scheduler = "scx_lavd";

    services.ollama = {
        enable = true;
        package = pkgs.ollama-cuda;
        loadModels = [ "qwen3.5:9b" "deepseek-r1:8b" ];
    };

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
    environment.systemPackages = with pkgs; [
        wayvr
        #TODO: disable stardust-xr for now
        #stardust-xr-server
        #stardust-xr-flatland
        #stardust-xr-atmosphere
        #stardust-xr-protostar
        #stardust-xr-kiara
    ];
    #programs.cdemu.enable = true;
    programs.coolercontrol = {
        enable = true;
    };
}

