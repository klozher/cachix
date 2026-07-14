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
    klozher.tmpfs-on-root = {
        enable = true;
        persistDev = {
            device = "UUID=eb03b3d0-f583-4ada-a443-599351936f17";
            fsType = "f2fs";
            options = [ "compress_algorithm=zstd:6" "compress_chksum" "atgc" "gc_merge" "lazytime" ];
        };
    };
    fileSystems = {
        "/boot" = {
            device = "UUID=3202-7389";
            fsType = "vfat";
            options = [ "fmask=0077" "dmask=0077" ];
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
        display = {
            edid.enable = true;
            #edid.modelines."MS82" = "148.500 1920 2448 2492 2640 1080 1084 1089 1125 +hsync +vsync";
            edid.packages = [(pkgs.runCommand "edid-custom" {} ''
                mkdir -p "$out/lib/firmware/edid"
                base64 -d > "$out/lib/firmware/edid/MS82.bin" << 'EOF'
                AP///////wBQbAAAAAAAAAkVAQOBUi54C9mwo1dJnCURSUuhDACVALMAgcCBAIFAgYCBwNHAGyFQ
                oFEAHjBIiDUAAAAAAAAADh8AgFEAHjBAgDcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/ABN
                UzgyCiAgICAgICAgAQMCAyDxTQUCAwQHEBESExQVFh8jCVcHgwEAAGUDDAAQAIwK0Iog4C0QED6W
                AGXMIQAAGAEdALxS0B4guChVQDLMMQAAHgEdgNByHBYgECwlgDLMMQAAnowK0Iog4C0QED6WADLM
                MQAAGIwK0JAgQDEgDEBVADLMMQAAGAAAAAAAFA==
                EOF
            '')];
            outputs."HDMI-A-1".edid = "MS82.bin";
            outputs."HDMI-A-1".mode = "1920x1080@60e";
        };
    };
}
