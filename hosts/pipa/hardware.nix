{ config, pkgs, lib, inputs, ... }:
let
    pipa-pkgs = pkgs.callPackage ./pipa-pkgs.nix {};
in
{
    boot = {
        kernelPackages = pkgs.linuxPackagesFor pipa-pkgs.pipa-kernel;
        kernelParams = [
            "resume=/dev/disk/by-partlabel/super"
#          "zswap.enabled=1" "zswap.compressor=zstd" "zswap.max_pool_percent=20" "zswap.shrinker_enabled=1"
        ];
        initrd = {
            systemd.enable = true;
            kernelModules = [
                "nt36523_ts"
                "panel_novatek_nt36532"
                "qcom_common"
                "qcom_pil_info"
                "qcom_q6v5"
                "qcom_q6v5_pas"
                "spi_geni_qcom"
            ];
            extraFirmwarePaths = [
                "novatek/nt36532_tianma.bin"
                "novatek/nt36532_csot.bin"
                "qcom/a650_sqe.fw"
                "qcom/a650_gmu.bin"
                "qcom/sm8250/xiaomi/pipa/a650_zap.mbn"
            ];
        };
        loader = {
            external.enable = true;
            external.installHook = "${pipa-pkgs.pipa-boot}/bin/pipa-boot";
        };
        tmp.useTmpfs = true;
        tmp.tmpfsSize = "100%";
    };

    swapDevices = [{ device = "/dev/disk/by-partlabel/super"; }];
    fileSystems = {
        "/".device = "none";
        "/".fsType = "tmpfs";
        "/".options = [ "defaults" "mode=755" ];

        "/@".device = "/dev/disk/by-partlabel/userdata";
        "/@".fsType = "f2fs";
        "/@".options = [ "noatime" ];

        "/nix".device = "/dev/disk/by-partlabel/userdata";
        "/nix".fsType = "f2fs";
        "/nix".options = [ "noatime" "X-mount.subdir=nix" ];

        "/home".device = "/dev/disk/by-partlabel/userdata";
        "/home".fsType = "f2fs";
        "/home".options = [ "noatime" "X-mount.subdir=home" ];

        "/persist".device = "/dev/disk/by-partlabel/userdata";
        "/persist".fsType = "f2fs";
        "/persist".options = [ "noatime" "X-mount.subdir=persist" ];
        "/persist".neededForBoot = true;
    };
    hardware = {
        firmware = [ pipa-pkgs.firmware-pipa pkgs.linux-firmware ];
        graphics.enable = true;
        bluetooth.enable = true;
        sensor.iio.enable = true;
    };
    environment = {
        sessionVariables = {
            ALSA_CONFIG_UCM2 = "${pipa-pkgs.pipa-device}/share/alsa/ucm2";
        };
    };
    services = {
        pipewire.enable = false;
        pulseaudio.enable = true;
        logind.settings.Login.HandlePowerKey = "lock";
        udev.packages = [pipa-pkgs.pipa-device];
    };
    systemd.services = {
        qbootctl = {
            description = "Mark a successful boot";
            wantedBy = ["sysinit.target"];
            serviceConfig = {
                Type = "oneshot";
                ExecStart = "${pkgs.qbootctl}/bin/qbootctl -m";
            };
        };
    };
}

