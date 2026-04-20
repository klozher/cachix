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
    fileSystems = {
        "/" = {
            device = "tmpfs";
            fsType = "tmpfs";
            options = [ "defaults" "mode=755" ];
        };
        "/boot" = {
            device = "UUID=11B3-D212";
            fsType = "vfat";
            options = [ "fmask=0077" "dmask=0077" ];
        };
        "/nix" = {
            device = "UUID=ac89eaec-6741-45d0-be21-fefc89b36470";
            fsType = "f2fs";
            options = [ "X-mount.subdir=nix" ] ++
                      [ "compress_algorithm=zstd:6" "compress_chksum" "atgc" "gc_merge" "lazytime" ];
        };
        "/persist" = {
            device = "UUID=ac89eaec-6741-45d0-be21-fefc89b36470";
            fsType = "f2fs";
            neededForBoot = true;
            options = [ "X-mount.subdir=persist" ] ++
                      [ "compress_algorithm=zstd:6" "compress_chksum" "atgc" "gc_merge" "lazytime" ];
        };
#        "/home" = {
#            device = "UUID=ac89eaec-6741-45d0-be21-fefc89b36470";
#            fsType = "f2fs";
#            options = [ "X-mount.subdir=home" ] ++
#                      [ "compress_algorithm=zstd:6" "compress_chksum" "atgc" "gc_merge" "lazytime" ];
#        };
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
#    environment.systemPackages = with pkgs; [
#        libGL
#        egl-wayland
#    ];
}
