{ config, pkgs, lib, inputs, ... }:
let
    pmports = pkgs.fetchFromGitLab {
        domain = "gitlab.postmarketos.org";
        owner = "postmarketOS";
        repo = "pmaports";
        rev = "a184bf63e21ec6b51598125810be7eefb73e6261";
        hash = "sha256-sDk9eHDtmDYJ83IRz3KqXDOW/H0E4zAzhPU5fuujmKo=";
    };
    pipa-firmware = pkgs.stdenvNoCC.mkDerivation {
        pname = "pipa-firmware";
        version = "2024-12-29";
        src = pkgs.fetchFromGitHub {
            owner = "pipa-mainline";
            repo = "xiaomi-pipa-firmware";
            rev = "842d35beffeda8c6d1b0e611b335543bf0e6b41e";
            hash = "sha256-NPApyQVkcDXcxNh1AK863r6VQGP4VQMapoFgHYni8fA=";
        };
        phases = [ "unpackPhase" "installPhase" ];
        installPhase = ''
            mkdir $out
            cp -r usr/share $out/
            cp -r lib $out/
            mkdir "$out/lib/firmware/qcom";
            mv "$out/lib/firmware/sm8250" "$out/lib/firmware/qcom/"
        '';
    };
    pipa-boot = pkgs.writeShellApplication {
        name = "pipa-boot";
        runtimeInputs = with pkgs; [ coreutils jq android-tools qbootctl gzip gawk ];
        text = ''
          bootspec="$1/boot.json"
          kernel="$(jq -r '."org.nixos.bootspec.v1"."kernel"' "$bootspec")"
          initrd="$(jq -r '."org.nixos.bootspec.v1"."initrd"' "$bootspec")"
          params="$(jq -r '."org.nixos.bootspec.v1"."kernelParams" | join(" ")' "$bootspec")"
          init="$(jq -r '."org.nixos.bootspec.v1"."init"' "$bootspec")"
          dtb="$(dirname "$kernel")/dtbs/qcom/sm8250-xiaomi-pipa-csot.dtb"

          echo "Building android boot ..."

          kernel_gz="/tmp/Image.gz"
          kernel_gz_dtb="/tmp/Image.gz-dtb"
          boot_img="/tmp/boot.img"

          gzip -ckf "$kernel" > "$kernel_gz"
          cat "$kernel_gz" "$dtb" > "$kernel_gz_dtb"

          mkbootimg \
            --header_version 0 \
            --kernel_offset 0x00008000 \
            --base 0x00000000 \
            --ramdisk_offset 0x01000000 \
            --second_offset 0x00f00000 \
            --tags_offset 0x00000100 \
            --pagesize 4096 \
            --kernel "$kernel_gz_dtb" \
            --ramdisk "$initrd" \
            --cmdline "$params init=$init" \
            -o "$boot_img"

          echo "Boot has been built to $boot_img"

          CURR_SLOT=$(qbootctl -c | awk '{print $3}')
          if [[ -z "$CURR_SLOT" ]]; then
              echo "qbootctl failed"
              exit 1
          fi
          BACK_SLOT=$([[ "$CURR_SLOT" == "_a" ]] && echo "_b" || echo "_a")
          CURR_SLOT_PATH="/dev/disk/by-partlabel/boot$CURR_SLOT"
          BACK_SLOT_PATH="/dev/disk/by-partlabel/boot$BACK_SLOT"

          if [[ ! -e "$CURR_SLOT_PATH" || ! -e "$BACK_SLOT_PATH" ]]; then
              echo "no boot parts"
              exit 1
          fi

          if [[ ! -e /run/pipa-booted-part-already-backed-up ]]; then
              echo "Backing up from $CURR_SLOT_PATH to $BACK_SLOT_PATH"
              dd if="$CURR_SLOT_PATH" of="$BACK_SLOT_PATH"
              touch /run/pipa-booted-part-already-backed-up
          fi

          echo "Flashing to $CURR_SLOT_PATH"
          dd if="$boot_img" of="$CURR_SLOT_PATH"

          rm "$kernel_gz" "$kernel_gz_dtb" "$boot_img"
        '';
    };
    pipa-device = pkgs.symlinkJoin {
        name = "pipa-device";
        paths = [ pkgs.alsa-ucm-conf ];
        postBuild = ''
            device_xiaomi_pipa="${pmports}/device/testing/device-xiaomi-pipa"
            install -Dm644 "$device_xiaomi_pipa/81-libssc-xiaomi-pipa.rules" -t "$out/lib/udev/rules.d/"
            install -Dm644 "$device_xiaomi_pipa/hexagonrpcd-sdsp.conf" -t "$out/share/hexagonrpcd/"
            install -Dm644 "$device_xiaomi_pipa/pipa.conf" -t "$out/share/alsa/ucm2/Xiaomi/pipa/"
            install -Dm644 "$device_xiaomi_pipa/HiFi.conf" -t "$out/share/alsa/ucm2/Xiaomi/pipa/"
            ln -s "../../Xiaomi/pipa/pipa.conf" "$out/share/alsa/ucm2/conf.d/sm8250/Xiaomi Pad 6.conf"
        '';
    };
    bootmac = pkgs.stdenv.mkDerivation rec {
        pname = "bootmac";
        version = "0.7.1";
        src = pkgs.fetchFromGitLab {
          domain = "gitlab.postmarketos.org";
          owner = "postmarketOS";
          repo = "bootmac";
          rev = "v${version}";
          hash = "sha256-GWvZUC8LKPpOWt1oCr93JHg5+W+0CCiYT63VhpSH1ko=";
        };
        nativeBuildInputs = with pkgs; [ meson ninja makeWrapper ];
        mesonFlags = [ "-Dsystemd_units=true" ];
        postInstall = ''
          substituteInPlace $out/lib/systemd/system/bootmac@.service \
            --replace-fail "/usr/bin" "$out/bin"
          substituteInPlace $out/lib/udev/rules.d/90-bootmac-bluetooth.rules \
            --replace-fail "/usr/bin" "$out/bin"
          substituteInPlace $out/lib/udev/rules.d/90-bootmac-wifi.rules \
            --replace-fail "/usr/bin" "$out/bin"
          wrapProgram $out/bin/bootmac --prefix PATH : ${lib.makeBinPath (with pkgs; [ coreutils gnugrep util-linux gnused bluez gawk ])}
        '';
    };
in
{
    boot = {
        kernelPackages = pkgs.linuxPackages_6_19;
        kernelPatches = [{
            patch = null;
            structuredExtraConfig = {
                ARM64_ERRATUM_1286807 = lib.kernel.yes;
                ARM64_ERRATUM_1542419 = lib.kernel.yes;
                ARM64_ERRATUM_2441007 = lib.kernel.yes;
                ARM64_ERRATUM_2441009 = lib.kernel.yes;
            };
        } {
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
                TOUCHSCREEN_NT36523_SPI = lib.kernel.module;
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
            availableKernelModules = [
                # bluetooth and camera only work in real rootfs
                #"hci_uart"
                #"qcom_camss"
                "apr"
                "bq25980_charger"
                "camcc_sm8250"
                "dm_cache_smq"
                "fastrpc"
                "fsa4480"
                "gpi"
                "gpio_keys_polled"
                "i2c_qcom_cci"
                "i2c_qcom_geni"
                "icc_bwmon"
                "icc_osm_l3"
                "ktz8866"
                "lattice_sysconfig_spi"
                "leds_qcom_flash"
                "leds_qcom_lpg"
                "llcc_qcom"
                "lpass_gfm_sm8250"
                "msm"
                "nt36523_ts"
                "ov13b10"
                "panel_novatek_nt36532"
                "pci_pwrctrl_pwrseq"
                "phy_qcom_qmp_combo"
                "phy_qcom_qmp_pcie"
                "phy_qcom_qmp_ufs"
                "phy_qcom_qmp_usb"
                "phy_qcom_qmp_usb_legacy"
                "phy_qcom_snps_femto_v2"
                "pinctrl_sm8250_lpass_lpi"
                "pwrseq_qcom_wcn"
                "q6adm"
                "q6afe"
                "q6afe_clocks"
                "q6afe_dai"
                "q6asm"
                "q6asm_dai"
                "q6core"
                "q6routing"
                "qcom_fg"
                "qcom_pmic_tcpm"
                "qcom_pon"
                "qcom_q6v5_pas"
                "qcom_refgen_regulator"
                "qcom_rng"
                "qcom_spmi_adc5"
                "qcom_spmi_adc_tm5"
                "qcom_spmi_temp_alarm"
                "qcom_stats"
                "qcom_usb_vbus_regulator"
                "qcom_wdt"
                "qcom_wled"
                "qcomsmempart"
                "qcrypto"
                "ramoops"
                "rcpufreq_dt"
                "rtc_pm8xxx"
                "sg2044_topsys"
                "snd_soc_aw88261"
                "snd_soc_lpass_rx_macro"
                "snd_soc_lpass_tx_macro"
                "snd_soc_lpass_va_macro"
                "snd_soc_lpass_wsa_macro"
                "snd_soc_sm8250"
                "snd_soc_wcd938x"
                "soundwire_qcom"
                "spi_geni_qcom"
                "ufs_qcom"
                "venus_core"
            ];
            extraFirmwarePaths = [
                "novatek/nt36532_tianma.bin"
                "novatek/nt36532_csot.bin"
                "qcom/sm8250/xiaomi/pipa/venus.mbn"
                "qcom/a650_sqe.fw"
                "qcom/a650_gmu.bin"
                "qcom/sm8250/xiaomi/pipa/a650_zap.mbn"
            ];
        };
        loader = {
            external.enable = true;
            external.installHook = "${pipa-boot}/bin/pipa-boot";
        };
    };

    swapDevices = [{ device = "/dev/disk/by-partlabel/super"; }];
    klozher.tmpfs-on-root = {
        enable = true;
        persistDev = {
            device = "/dev/disk/by-partlabel/userdata";
            fsType = "f2fs";
            options = [ "compress_algorithm=zstd:6" "compress_chksum" "atgc" "gc_merge" "lazytime" ];
        };
    };
    systemd.packages = [ bootmac ];
    hardware = {
        firmware = [ pkgs.linux-firmware pipa-firmware ];
        graphics.enable = true;
        bluetooth.enable = true;
        sensor.iio.enable = true;
    };
    environment = {
        sessionVariables = {
            ALSA_CONFIG_UCM2 = "${pipa-device}/share/alsa/ucm2";
        };
    };
    services = {
        pipewire.enable = false;
        pulseaudio.enable = true;
        udev.packages = [ pipa-device bootmac ];
        udev.extraRules = ''
            SUBSYSTEM=="misc", KERNEL=="fastrpc-adsp*", ENV{IIO_SENSOR_PROXY_TYPE}+="ssc-accel ssc-proximity"
            SUBSYSTEM=="misc", KERNEL=="fastrpc-sdsp*", ENV{IIO_SENSOR_PROXY_TYPE}+="ssc-accel ssc-proximity"
        '';
    };
    systemd.services = {
        qbootctl-mark-successful = {
            description = "Mark a successful boot";
            after = ["graphical.target"];
            wantedBy = ["graphical.target"];
            serviceConfig = {
                Type = "oneshot";
                ExecStart = "${pkgs.qbootctl}/bin/qbootctl -m";
            };
        };
        hexagonrpc-sdsp = {
            description = "Hexagonrpcd SDSP Daemon to support Qualcomm Hexagon SDSP virtual filesystem";
            requires = ["dev-fastrpc\\x2dsdsp.device"];
            after = ["dev-fastrpc\\x2dsdsp.device"];
            requiredBy = ["iio-sensor-proxy.service"];
            before = ["iio-sensor-proxy.service"];
            serviceConfig = {
                ExecStart = with pkgs; ''
                    ${hexagonrpc}/bin/hexagonrpcd -s -f /dev/fastrpc-sdsp -R ${pipa-firmware}/share/qcom/sm8250/Xiaomi/pipa
                '';
            };
        };
    };
}

