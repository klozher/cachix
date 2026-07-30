#{lib, stdenv, writeText, callPackage, ...}@pkgs: rec {
{
lib,
stdenv,
stdenvNoCC,
writeText,
symlinkJoin,
callPackage,
fetchFromGitHub,
fetchFromGitLab,
alsa-ucm-conf,
meson,
ninja,
makeWrapper,
coreutils,
gnugrep,util-linux,gnused,bluez,gawk,iproute2,
...}@pkgs: rec {
    pmports = fetchFromGitLab {
        domain = "gitlab.postmarketos.org";
        owner = "postmarketOS";
        repo = "pmaports";
        rev = "db1fe3c1c118e5259246f3cd3fcbeeb4e44a9eeb";
        hash = "sha256-MAFc90rO97xOH/zB/4fY1lNyLVsjAMB5HyEifMvZVrg=";
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
    pipa-device = symlinkJoin {
        name = "pipa-device";
        paths = [ alsa-ucm-conf ];
        postBuild = ''
            device_xiaomi_pipa="${pmports}/device/testing/device-xiaomi-pipa"
            install -Dm644 "$device_xiaomi_pipa/81-libssc-xiaomi-pipa.rules" -t "$out/lib/udev/rules.d/"
            install -Dm644 "$device_xiaomi_pipa/pipa.conf" -t "$out/share/alsa/ucm2/Xiaomi/pipa/"
            install -Dm644 "$device_xiaomi_pipa/HiFi.conf" -t "$out/share/alsa/ucm2/Xiaomi/pipa/"
            ln -s "../../Xiaomi/pipa/pipa.conf" "$out/share/alsa/ucm2/conf.d/sm8250/xiaomi-XiaomiPad6.conf"
            install -Dm644 "$device_xiaomi_pipa/local-overrides.quirks" -t "$out/etc/libinput/"
        '';
    };
    bootmac = stdenv.mkDerivation rec {
        pname = "bootmac";
        version = "0.7.1";
        src = fetchFromGitLab {
          domain = "gitlab.postmarketos.org";
          owner = "postmarketOS";
          repo = "bootmac";
          rev = "v${version}";
          hash = "sha256-GWvZUC8LKPpOWt1oCr93JHg5+W+0CCiYT63VhpSH1ko=";
        };
        nativeBuildInputs = [ meson ninja makeWrapper ];
        mesonFlags = [ "-Dsystemd_units=true" ];
        postInstall = ''
          substituteInPlace $out/lib/systemd/system/bootmac@.service \
            --replace-fail "/usr/bin" "$out/bin"
          substituteInPlace $out/lib/udev/rules.d/90-bootmac-bluetooth.rules \
            --replace-fail "/usr/bin" "$out/bin"
          substituteInPlace $out/lib/udev/rules.d/90-bootmac-wifi.rules \
            --replace-fail "/usr/bin" "$out/bin"
          wrapProgram $out/bin/bootmac --prefix PATH : ${lib.makeBinPath [ coreutils gnugrep util-linux gnused bluez gawk iproute2 ]}
        '';
    };
    fsa4480-nodev-fix = writeText "fsa4480-nodev-fix.patch" ''
        diff --git a/drivers/usb/typec/mux/fsa4480.c b/drivers/usb/typec/mux/fsa4480.c
        index c54e42c..a7a8284 100644
        --- a/drivers/usb/typec/mux/fsa4480.c
        +++ b/drivers/usb/typec/mux/fsa4480.c
        @@ -280,7 +280,7 @@ static int fsa4480_probe(struct i2c_client *client)
         
         	ret = regmap_read(fsa->regmap, FSA4480_DEVICE_ID, &val);
         	if (ret)
        -		return dev_err_probe(dev, -ENODEV, "FSA4480 not found\n");
        +		return dev_err_probe(dev, -EPROBE_DEFER, "FSA4480 not found\n");
         
         	dev_dbg(dev, "Found FSA4480 v%lu.%lu (Vendor ID = %lu)\n",
         		FIELD_GET(FSA4480_DEVICE_ID_VERSION_ID, val),
    '';
    linux_pipa = callPackage ({buildLinux, fetchurl, ...}: buildLinux {
        src = fetchurl {
            url = "mirror://kernel/linux/kernel/v7.x/linux-7.1.4.tar.xz";
            hash = "sha256-HGOSKhGWddOOOuD49u4H8VxBp4arntZlY3SbuMmgji4=";
        };
        version = "7.1.4";
        isLTS = false;
        modDirVersion = lib.versions.pad 3 "7.1.4";
        extraMeta.branch = "7.1";
        kernelPatches = [{
            patch = "${fsa4480-nodev-fix}";
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
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0004-drm-msm-dsi-change-sync-mode-to-sync-on-DSI0-rather-.patch";
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0005-drm-msm-dsi-support-DSC-configurations-with-slice_pe.patch";
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0006-drm-panel-Add-support-for-Novatek-NT36532-panel.patch";
            structuredExtraConfig = {
                DRM_PANEL_NOVATEK_NT36532 = lib.kernel.module;
            };
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0007-drivers-media-i2c-ov13b10-add-device-tree-support-an.patch";
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0008-ASoC-qcom-sm8250-add-tertiary-tdm-support.patch";
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0010-HACK-ASoC-codecs-aw88261-add-xiaomi-pipa-hacks.patch";
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0011-FROMLIST-ASoC-qcom-qdsp6-q6afe-fix-clk-vote-response.patch";
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0012-HACK-ASoC-qcom-qdsp6-q6afe-pretend-the-AFE-vote-didn.patch";
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0013-Input-keyboard-add-Xiaomi-Nanosic-803-keyboard.patch";
            structuredExtraConfig = {
                KEYBOARD_XIAOMI_NANOSIC803 = lib.kernel.module;
            };
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0014-UPSTREAM-libbpf-Fix-UAF-in-strset__add_str.patch";
        } {
            patch = "${pmports}/device/testing/linux-xiaomi-pipa/0016-power-supply-add-nuvolta-rx1665-wireless-charger.patch";
            structuredExtraConfig = {
                FUDA_1665 = lib.kernel.module;
            };
        }];
    }) {};
}

