{ config, pkgs, lib, inputs, ... }:
let
    pipa-pkgs = pkgs.callPackage ./pipa-pkgs.nix {};
in
{
    boot = {
        kernelPackages = pkgs.linuxPackages_6_19;
        kernelPatches = with pipa-pkgs; [{
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0001-arm64-dts-qcom-sm8250-xiaomi-pipa-Add-device-tree-fo.patch";
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0002-power-supply-Add-driver-for-Qualcomm-PMIC-fuel-gauge.patch";
            structuredExtraConfig = {
                CHARGER_QCOM_SMB5 = lib.kernel.yes;
                BATTERY_QCOM_FG = lib.kernel.module;
            };
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0003-Input-Add-nt36523-touchscreen-driver.patch";
            structuredExtraConfig = {
                CHARGER_QCOM_SMB5 = lib.kernel.yes;
                BATTERY_QCOM_FG = lib.kernel.module;
                SPI_MT65XX = lib.kernel.no;
            };
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0004-drm-Add-drm-notifier-support.patch";
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0005-drm-dsi-emit-panel-turn-on-off-signal-to-touchscreen.patch";
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0006-drm-msm-dsi-change-sync-mode-to-sync-on-DSI0-rather-.patch";
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0007-drm-msm-dsi-support-DSC-configurations-with-slice_pe.patch";
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0008-drm-panel-Add-support-for-Novatek-NT36532-panel.patch";
            structuredExtraConfig = {
                DRM_PANEL_NOVATEK_NT36532 = lib.kernel.module;
            };
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0009-drivers-media-i2c-ov13b10-add-device-tree-support-an.patch";
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0010-ASoC-codecs-aw88261-add-hacks-for-xiaomi-pipa.patch";
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0011-ASoC-qcom-sm8250-Add-tdm-support.patch";
        }];
        kernelParams = [
            "resume=/dev/disk/by-partlabel/super"
#          "zswap.enabled=1" "zswap.compressor=zstd" "zswap.max_pool_percent=20" "zswap.shrinker_enabled=1"
        ];
        initrd = {
            systemd.enable = true;
            includeDefaultModules = false;
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

    hardware = {
        firmware = [ pipa-pkgs.pipa-firmware pkgs.linux-firmware ];
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

