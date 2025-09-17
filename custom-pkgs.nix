{
    fetchurl,
    fetchFromGitHub,
    stdenv,
    stdenvNoCC,
    applyPatches,
    writeText,
    writeShellApplication,

    meson,
    ninja,
    pkg-config,

    linuxPackages_custom,
    coreutils,
    android-tools,
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
}@args: rec {
    void-pipa = fetchFromGitHub {
        owner = "pipa-mainline";
        repo = "void-pipa";
        rev = "e65b6ee2ed58694f3b177c43c7d3ffbfe10ded22";
        hash = "sha256-b9BldBJZFxGZnAq9BMrxNejRwBB7cC/QGtjFwdncihw=";
    };
    linux-pipa = linuxPackages_custom {
        version = "6.15.8";
        modDirVersion = "6.15.8-sm8250-adomerle";
        src = fetchFromGitHub {
            owner = "pipa-mainline";
            repo = "linux";
            rev = "pipa-6.15.8";
            hash = "sha256-Bg5FkG3ahGbFB4FsVdTzdlHYZ9AJY8vNBVeKY/55+QA=";
        };
        configfile = let pipa-config = applyPatches {
            name = "pipa-config";
            src = "${void-pipa}/packages/linux6.15-pipa/files/pipa.config";
            dontUnpack = true;
            prePatch = "cp $src ./";
            patches = [(writeText "pipa-config.patch" ''
                --- a/pipa.config   2025-07-08 22:52:05.069059483 +0800
                --- b/pipa.config   2025-07-08 22:52:05.069059483 +0800
                @@ -963 +963,2 @@
                -# CONFIG_ZSWAP is not set
                +CONFIG_ZSWAP=y
                +CONFIG_ZSWAP_COMPRESSOR_DEFAULT_ZSTD=y
                @@ -5490 +5491 @@
                -# CONFIG_HID_SENSOR_HUB is not set
                +CONFIG_HID_SENSOR_HUB=y
                @@ -7522 +7523 @@
                -# CONFIG_ANDROID_BINDERFS is not set
                +CONFIG_ANDROID_BINDERFS=y
                ''
            )];
        }; in "${pipa-config}/pipa.config";
    };
    firmware-pipa = stdenvNoCC.mkDerivation {
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
    qbootctl = stdenv.mkDerivation {
        pname = "qbootctl";
        version = "0.2.2";
        nativeBuildInputs = [ meson ninja linuxHeaders];
            src = fetchFromGitHub {
            owner = "linux-msm";
            repo = "qbootctl";
            rev = "0.2.2";
            hash = "sha256-lpDCU9RJ4pK/qX4dEFfOCEdsF7l4Z/J8wzWMD4orFQY=";
        };
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
          dtb="$(dirname "$kernel")/dtbs/qcom/sm8250-xiaomi-pipa.dtb"

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
    bluez-fix = bluez.overrideAttrs {
        src = fetchFromGitHub {
            owner = "bluez";
            repo = "bluez";
            rev = "f9a98ff26e505abdf55845a5d80a57a5defd6299";
            hash = "sha256-sZ7B0NPdv9OpGIx7+24uONpkFnEKx/JquZ+eNjN5kPU=";
        };
    };
    alsa-ucm-conf-pipa = symlinkJoin {
        name = "alsa-ucm-conf-pipa";
        paths = [ alsa-ucm-conf ];
        postBuild = ''
            mkdir -p "$out/share/alsa/ucm2/Xiaomi/pipa"
            cp "${void-pipa}/packages/pipa-alsa-ucm/files/HiFi.conf" "$out/share/alsa/ucm2/Xiaomi/pipa/"
            cp "${void-pipa}/packages/pipa-alsa-ucm/files/Xiaomi Pad 6.conf" "$out/share/alsa/ucm2/conf.d/sm8250/"
        '';
    };
    libssc = stdenv.mkDerivation {
        pname = "libssc";
        version = "0.2.2";
        buildInputs = [ glib libqmi ];
        nativeBuildInputs = [ meson ninja pkg-config protobuf protobufc ];
        src = fetchurl {
            url = "https://codeberg.org/DylanVanAssche/libssc/archive/v0.2.2.tar.gz";
            hash = "sha256-TZ4q5LBUjxmtU6VtNl1y4x0rtytM57I0oraYdbwkJo8=";
        };
    };
    hexagonrpc = stdenv.mkDerivation {
        pname = "hexagonrpc";
        version = "0.4.0";
        nativeBuildInputs = [ meson ninja ];
        src = fetchFromGitHub {
            owner = "linux-msm";
            repo = "hexagonrpc";
            rev = "v0.4.0";
            hash = "sha256-OC6wXBCIW4XznWG0zzxRK3BzWMVK2Jq/gTL36sJV1PE=";
        };
    };
    iio-sensor-proxy-ssc = iio-sensor-proxy.overrideAttrs (prevAttrs: {
        buildInputs = prevAttrs.buildInputs ++ [ libssc libqmi ];
        patches = [(fetchurl {
            url = "https://gitlab.freedesktop.org/hadess/iio-sensor-proxy/-/merge_requests/381/diffs.patch";
            hash = "sha256-S2GTxqP8SC3FNPvH3dmQu97GY1LZnLLWpIxKNUj0tGo=";
        })];
        postInstall = ''
            sed -i "s/ ssc-light ssc-proximity ssc-compass//g" $out/lib/udev/rules.d/80-iio-sensor-proxy.rules
            cp ${void-pipa}/packages/pipa-sensors/files/81-libssc-xiaomi-pipa.rules $out/lib/udev/rules.d/
        '';
    });
}
