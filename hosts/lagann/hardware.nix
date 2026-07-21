{ config, pkgs, lib, inputs, ... }:
{
    boot = {
        loader.timeout = null;
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
            device = "UUID=2f2e05a2-3f1e-4530-a769-c6b6ad6c7885";
            fsType = "btrfs";
            options = [ "noatime" "ssd" "discard=async,space_cache=v2" "compress-force=zstd:3" ];
        };
    };
    fileSystems = {
        "/boot" = {
            device = "UUID=2f2e05a2-3f1e-4530-a769-c6b6ad6c7885";
            fsType = "btrfs";
            options = [ "noatime" "ssd" "discard=async,space_cache=v2" "subvol=boot" ];
        };
    };
    services.pipewire.enable = true;
    networking.firewall.enable = false;
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
