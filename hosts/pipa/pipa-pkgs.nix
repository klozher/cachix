{
lib,
fetchurl,
fetchFromGitHub,
fetchFromGitLab,
stdenv,
stdenvNoCC,
applyPatches,
writeText,
writeShellApplication,

meson,
ninja,
pkg-config,

buildLinux,
linuxManualConfig,
coreutils,
android-tools,
qbootctl,
gzip,
gawk,
jq,
glib,

linuxHeaders,
bluez,
symlinkJoin,
alsa-ucm-conf,
libqmi,
protobuf,
protobufc,
iio-sensor-proxy,
...
}:
let
    pmports = fetchFromGitLab {
        domain = "gitlab.postmarketos.org";
        owner = "postmarketOS";
        repo = "pmaports";
        rev = "a184bf63e21ec6b51598125810be7eefb73e6261";
        hash = "sha256-sDk9eHDtmDYJ83IRz3KqXDOW/H0E4zAzhPU5fuujmKo=";
    };
in {
    inherit pmports;
    pipa-kernel = linuxManualConfig {
        version = "6.19.12";
        src = fetchurl {
            url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.19.12.tar.xz";
            hash = "sha256-zlxPEgX5cpKGtWmwN2SVkVVfMcoeA8xQS9O3C45YqNU=";
        };
        allowImportFromDerivation = true;
        modDirVersion = "6.19.12-pipa";
        configfile = "${pmports}/device/testing/linux-xiaomi-pipa/config-xiaomi-pipa.aarch64";
        kernelPatches = [{
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0001-arm64-dts-qcom-sm8250-xiaomi-pipa-Add-device-tree-fo.patch";
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0002-power-supply-Add-driver-for-Qualcomm-PMIC-fuel-gauge.patch";
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0003-Input-Add-nt36523-touchscreen-driver.patch";
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
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0009-drivers-media-i2c-ov13b10-add-device-tree-support-an.patch";
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0010-ASoC-codecs-aw88261-add-hacks-for-xiaomi-pipa.patch";
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0011-ASoC-qcom-sm8250-Add-tdm-support.patch";
        }];
    };
    pipa-firmware = stdenvNoCC.mkDerivation {
        pname = "pipa-firmware";
        version = "2024-12-29";
        src = fetchFromGitHub {
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
    pipa-boot = writeShellApplication {
        name = "pipa-boot";
        runtimeInputs = [ coreutils jq android-tools qbootctl gzip gawk ];
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

          if [ -e "/dev/disk/by-partlabel/boot_a" ];then
            echo "Boot partition detected, reflashing..."
            slot=$(qbootctl -c | awk '{print $3}')
            echo "Detected boot slot: $slot"
            device="/dev/disk/by-partlabel/boot$slot"
            echo "Flashing to $device"
            dd if="$boot_img" of="$device"
          fi
          rm "$kernel_gz" "$kernel_gz_dtb" "$boot_img"
        '';
    };
    pipa-device = symlinkJoin {
        name = "pipa-device";
        paths = [ alsa-ucm-conf ];
        postBuild = ''
            device_xiaomi_pipa="${pmports}/device/testing/device-xiaomi-pipa"
            install -Dm644 "$device_xiaomi_pipa/81-libssc-xiaomi-pipa.rules" -t "$out/lib/udev/rules.d/"
            install -Dm644 "$device_xiaomi_pipa/hexagonrpcd-sdsp.conf" -t "$out/share/hexagonrpcd/"
            install -Dm644 "$device_xiaomi_pipa/pipa.conf" -t "$out/share/alsa/ucm2/Xiaomi/pipa/"
            install -Dm644 "$device_xiaomi_pipa/HiFi.conf" -t "$out/share/alsa/ucm2/Xiaomi/pipa/"
            ln -s "../../Xiaomi/pipa/pipa.conf" "$out/share/alsa/ucm2/conf.d/sm8250/Xiaomi Pad 6.conf"
        '';
    };
    bootmac = stdenvNoCC.mkDerivation rec {
        pname = "bootmac";
        version = "0.7.1";
        src = fetchFromGitLab {
          domain = "gitlab.postmarketos.org";
          owner = "postmarketOS";
          repo = "bootmac";
          rev = "v${version}";
          hash = "sha256-GWvZUC8LKPpOWt1oCr93JHg5+W+0CCiYT63VhpSH1ko=";
        };
        nativeBuildInputs = [
          meson
          ninja
        ];
        mesonFlags = [ "-Dsystemd_units=true" ];
        postInstall = ''
          substituteInPlace $out/lib/systemd/system/bootmac@.service \
            --replace-fail "/usr/bin" "$out/bin"
          '';

    };
}
