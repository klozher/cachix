{ config, pkgs, lib, inputs, ... }:
{
    boot = {
        loader.timeout = 0;
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        kernelParams = [];
        initrd.kernelModules = [ ];
        initrd.systemd.enable = true;
        tmp.useTmpfs = true;
        tmp.tmpfsSize = "100%";
        plymouth.enable = true;
        resumeDevice = "/dev/disk/by-uuid/c051bfb9-6dc7-42cd-a602-f35efeefd7ae";
    };

    swapDevices = [ { device = "/dev/disk/by-uuid/c051bfb9-6dc7-42cd-a602-f35efeefd7ae"; } ];
    klozher.tmpfs-on-root = {
        enable = true;
        persistDev = {
            device = "UUID=8b8b1227-fd63-4c06-982c-a88af3b66bcc";
            fsType = "bcachefs";
            options = [
                "noatime" "discard"
            ];
        };
    };
    fileSystems = {
        "/boot" = {
            device = "UUID=41A4-0088";
            fsType = "vfat";
            options = [ "fmask=0077" "dmask=0077" ];
        };
    };
    services.xserver.videoDrivers = [ "nvidia" ];
    services.pipewire.enable = true;
    hardware = {
        firmware = [ pkgs.linux-firmware ];
        graphics.enable = true;
        nvidia = {
            open = false;
            package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
            powerManagement.enable = true;
            nvidiaPersistenced = true;
        };
        bluetooth.enable = true;
        alsa.enablePersistence = true;
    };
}

