{ config, pkgs, lib, inputs, ... }:
{
    boot = {
        loader.timeout = 0;
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        kernelPackages = pkgs.linuxPackages;
        kernelParams = [];
        initrd.kernelModules = [ ];
        initrd.systemd.enable = true;
        tmp.useTmpfs = true;
        tmp.tmpfsSize = "100%";
        plymouth.enable = true;
        resumeDevice = "/dev/disk/by-uuid/af399dbc-bc72-4c13-882d-6a00f0270925";
    };

    swapDevices = [ { device = "/dev/disk/by-uuid/af399dbc-bc72-4c13-882d-6a00f0270925"; } ];
    fileSystems = {
        "/" = {
            device = "tmpfs";
            fsType = "tmpfs";
            options = [ "defaults" "mode=755" ];
        };
        "/boot" = {
            device = "UUID=3202-7389";
            fsType = "vfat";
            options = [ "fmask=0077" "dmask=0077" ];
        };
        "/nix" = {
            device = "UUID=eb03b3d0-f583-4ada-a443-599351936f17";
            fsType = "f2fs";
            options = [ "X-mount.subdir=nix" ] ++
                      [ "compress_algorithm=zstd:6" "compress_chksum" "atgc" "gc_merge" "lazytime" ];
        };
        "/persist" = {
            device = "UUID=eb03b3d0-f583-4ada-a443-599351936f17";
            fsType = "f2fs";
            neededForBoot = true;
            options = [ "X-mount.subdir=persist" ] ++
                      [ "compress_algorithm=zstd:6" "compress_chksum" "atgc" "gc_merge" "lazytime" ];
        };
        "/home" = {
            device = "UUID=eb03b3d0-f583-4ada-a443-599351936f17";
            fsType = "f2fs";
            options = [ "X-mount.subdir=home" ] ++
                      [ "compress_algorithm=zstd:6" "compress_chksum" "atgc" "gc_merge" "lazytime" ];
        };
        "/media" = {
            device = "UUID=eb03b3d0-f583-4ada-a443-599351936f17";
            fsType = "f2fs";
            options = [ "X-mount.subdir=media" ] ++
                      [ "compress_algorithm=zstd:6" "compress_chksum" "atgc" "gc_merge" "lazytime" ];
        };
        "/media/hdd0" = {
            device = "UUID=306535ad-9da7-44a1-b73b-0f94bc1cb11f";
            fsType = "btrfs";
            options = [ "subvol=@" ] ++
                      [ "noatime" "compress-force=zstd" ];
        };
        "/media/hdd1" = {
            device = "UUID=561ba687-8c47-470b-b21c-9488f7172b64";
            fsType = "btrfs";
            options = [ "subvol=@" ] ++
                      [ "noatime" "compress-force=zstd" ];
        };
    };
    services.nfs.server = {
        enable = true;
        exports = ''
            /media      192.168.1.0/24(insecure,rw,sync,no_subtree_check,crossmnt,fsid=0)
            /media/hdd0 192.168.1.0/24(insecure,rw,sync,no_subtree_check)
            /media/hdd1 192.168.1.0/24(insecure,rw,sync,no_subtree_check)
        '';
    };
    networking.firewall.allowedTCPPorts = [
        2049 #NFSv4
    ];
    networking.networkmanager.enable = true;
    hardware = {
        firmware = [ pkgs.linux-firmware ];
        graphics.enable = true;
    };
}
