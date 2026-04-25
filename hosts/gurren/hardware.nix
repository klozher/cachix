{ config, pkgs, lib, inputs, ... }:
{
    boot = {
        loader.timeout = 0;
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        kernelPackages = pkgs.linuxPackages_zen;
        kernelParams = [];
        initrd.kernelModules = [ ];
        initrd.systemd.enable = true;
        tmp.useTmpfs = true;
        tmp.tmpfsSize = "100%";
        plymouth.enable = true;
        resumeDevice = "/dev/disk/by-uuid/8f2bb26d-df41-432d-a92f-82371b42932e";
    };

    swapDevices = [ { device = "/dev/disk/by-uuid/8f2bb26d-df41-432d-a92f-82371b42932e"; } ];
    klozher.tmpfs-on-root = {
        enable = true;
        persistDev = {
            device = "UUID=ac89eaec-6741-45d0-be21-fefc89b36470";
            fsType = "f2fs";
            options = [ "compress_algorithm=zstd:6" "compress_chksum" "atgc" "gc_merge" "lazytime" ];
        };
    };
    fileSystems = {
        "/boot" = {
            device = "UUID=11B3-D212";
            fsType = "vfat";
            options = [ "fmask=0077" "dmask=0077" ];
        };
    };
    services.xserver.videoDrivers = [ "nvidia" ];
    services.pipewire.enable = true;
    networking.networkmanager.enable = true;
    hardware = {
        firmware = [ pkgs.linux-firmware ];
        graphics.enable = true;
        nvidia = {
            open = true;
            package = config.boot.kernelPackages.nvidiaPackages.beta;
            powerManagement.enable = true;
            nvidiaPersistenced = true;
        };
        bluetooth.enable = true;
        alsa.enablePersistence = true;
        openrazer = {
            enable = true;
            users = [ "sice" ];
        };
    };
}
