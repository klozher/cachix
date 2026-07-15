{ config, pkgs, lib, inputs, ... }:
{
    boot = {
        loader.timeout = 10;
        loader.grub.enable = true;
        loader.grub.device = "nodev";
        loader.grub.efiSupport = true;
        loader.grub.efiInstallAsRemovable = true;
        loader.efi.canTouchEfiVariables = false;
        kernelParams = [ ];
        initrd.kernelModules = [ "uas" ];
        initrd.systemd.enable = true;
        tmp.useTmpfs = true;
        tmp.tmpfsSize = "100%";
        supportedFilesystems = [ "bcachefs" ];
    };

    klozher.tmpfs-on-root = {
        enable = true;
        persistDev = {
            device = "UUID=847c00f5-3329-4117-bba9-f0de957056a7";
            fsType = "btrfs";
            options = [ "compress-force=zstd:3" "noatime" "subvol=@" ];
        };
    };
    fileSystems = {
        "/boot" = {
            device = "UUID=847c00f5-3329-4117-bba9-f0de957056a7";
            fsType = "btrfs";
            options = [ "compress-force=zstd:3" "noatime" "subvol=@/boot" ];
        };
    };
    services.pipewire.enable = true;
    networking.networkmanager.enable = true;
    hardware = {
        firmware = [ pkgs.linux-firmware ];
        graphics.enable = true;
        bluetooth.enable = true;
        alsa.enablePersistence = true;
    };
    specialisation.NVIDIA-LATEST.configuration = {
        services.xserver.videoDrivers = [ "nvidia" ];
        hardware.nvidia = {
            open = true;
            package = config.boot.kernelPackages.nvidiaPackages.stable;
        };
    };
    specialisation.NVIDIA-580.configuration = {
        services.xserver.videoDrivers = [ "nvidia" ];
        hardware.nvidia = {
            open = false;
            package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
        };
    };
}
