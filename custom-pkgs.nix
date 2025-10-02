{
    lib,
    pkgsCross,
    fetchurl,
    fetchFromGitHub,
    stdenv,
    stdenvNoCC,
    applyPatches,
    writeText,
    writeShellApplication,

    cmake,
    meson,
    ninja,
    pkg-config,
    python3,
    nasm,

    linuxPackages_custom,
    coreutils,
    android-tools,
    gzip,
    gawk,
    jq,
    glib,
    xxHash,
    git,
    glibc,

    linuxHeaders,
    bluez,
    symlinkJoin,
    alsa-ucm-conf,
    libqmi,
    protobuf,
    protobufc,
    iio-sensor-proxy,
    wineWow64Packages,
    llvmPackages_21,
    fex-headless,
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
        arm64ec-w64-mingw32-system = (lib.systems.elaborate lib.systems.examples.ucrtAarch64) // {
            config = "arm64ec-w64-mingw32";
            system = "arm64ec-windows";
        };

        aarch64-w64-mingw32-pkgs = pkgsCross.ucrtAarch64;
        aarch64-w64-mingw32-build = aarch64-w64-mingw32-pkgs.buildPackages;

        arm64ec-w64-mingw32-stdenv = aarch64-w64-mingw32-pkgs.stdenv.override {
            hostPlatform = arm64ec-w64-mingw32-system;
            targetPlatform = arm64ec-w64-mingw32-system;
        };
        arm64ec-w64-mingw32-stdenvNoCC = aarch64-w64-mingw32-pkgs.stdenvNoCC.override {
            hostPlatform = arm64ec-w64-mingw32-system;
            targetPlatform = arm64ec-w64-mingw32-system;
        };
        arm64ec-w64-mingw32-callPackage = aarch64-w64-mingw32-pkgs.newScope arm64ec-w64-mingw32-override;
        arm64ec-w64-mingw32-override = {
            stdenv = arm64ec-w64-mingw32-stdenv;
            stdenvNoCC = arm64ec-w64-mingw32-stdenvNoCC;
            callPackage = arm64ec-w64-mingw32-callPackage;
        };

        arm64ec-w64-mingw32-build-stdenv = aarch64-w64-mingw32-build.stdenv.override {
            targetPlatform = arm64ec-w64-mingw32-system;
        };
        arm64ec-w64-mingw32-build-stdenvNoCC = aarch64-w64-mingw32-build.stdenvNoCC.override {
            targetPlatform = arm64ec-w64-mingw32-system;
        };
        arm64ec-w64-mingw32-build-callPackage = aarch64-w64-mingw32-build.newScope arm64ec-w64-mingw32-build-override;
        arm64ec-w64-mingw32-build-override = {
            stdenv = arm64ec-w64-mingw32-build-stdenv;
            stdenvNoCC = arm64ec-w64-mingw32-build-stdenvNoCC;
            callPackage = arm64ec-w64-mingw32-build-callPackage;
        };

        arm64ec-w64-mingw32-build-llvm_21 = aarch64-w64-mingw32-build.llvmPackages_21.override ({
            targetLlvmLibraries = aarch64-w64-mingw32-build.targetPackages.llvmPackages_21.libraries // {
                compiler-rt-no-libc = arm64ec-w64-mingw32-compiler-rt-no-libc;
                compiler-rt = arm64ec-w64-mingw32-compiler-rt-libc;
                libcxx = arm64ec-w64-mingw32-libcxx;
                libunwind = arm64ec-w64-mingw32-libunwind;
            };
        } // arm64ec-w64-mingw32-build-override);
        arm64ec-w64-mingw32-build-bintoolsNoLibc = arm64ec-w64-mingw32-build-llvm_21.bintoolsNoLibc.override {
            stdenvNoCC = arm64ec-w64-mingw32-build-stdenvNoCC;
        };
        arm64ec-w64-mingw32-build-clangNoCompilerRt = arm64ec-w64-mingw32-build-llvm_21.clangNoCompilerRt.override {
            stdenvNoCC = arm64ec-w64-mingw32-build-stdenvNoCC;
            bintools = arm64ec-w64-mingw32-build-bintoolsNoLibc;
        };
        arm64ec-w64-mingw32-compiler-rt-no-libc = (aarch64-w64-mingw32-pkgs.llvmPackages_21.compiler-rt-no-libc.override {
            stdenv = aarch64-w64-mingw32-build.overrideCC arm64ec-w64-mingw32-stdenv arm64ec-w64-mingw32-build-clangNoCompilerRt;
            devExtraCmakeFlags = [(lib.cmakeFeature "CMAKE_SYSTEM_NAME" "Windows")];
        })
        .overrideAttrs (prevAttrs: {
            postInstall = prevAttrs.postInstall + ''
                arm64ec-w64-mingw32-llvm-lib -machine:arm64ec -out:$out/lib/windows/libclang_rt.builtins-aarch64.a \
                    $out/lib/windows/libclang_rt.builtins-arm64ec.a \
                    ${aarch64-w64-mingw32-pkgs.llvmPackages_21.compiler-rt-no-libc}/lib/windows/libclang_rt.builtins-aarch64.a
                rm $out/lib/windows/libclang_rt.builtins-arm64ec.a;
                ln -s $out/lib/windows/libclang_rt.builtins-aarch64.a $out/lib/windows/libclang_rt.builtins-arm64ec.a
            '';
        });
        arm64ec-w64-mingw32-build-clangNoLibc = arm64ec-w64-mingw32-build-llvm_21.clangNoLibc.override {
            stdenvNoCC = arm64ec-w64-mingw32-build-stdenvNoCC;
            bintools = arm64ec-w64-mingw32-build-bintoolsNoLibc;
        };
        arm64ec-w64-mingw32-build-clangNoLibcStdenv = aarch64-w64-mingw32-build.overrideCC arm64ec-w64-mingw32-stdenvNoCC arm64ec-w64-mingw32-build-clangNoLibc;
        arm64ec-w64-mingw32-windows = aarch64-w64-mingw32-pkgs.windows.overrideScope (final: prev: {
            mingw_w64 = (prev.mingw_w64.override {
                stdenv = arm64ec-w64-mingw32-build-clangNoLibcStdenv;
            });
            mingw_w64_headers = (prev.mingw_w64_headers.override {
                stdenvNoCC = arm64ec-w64-mingw32-stdenvNoCC;
            });
            pthreads = (prev.pthreads.override {
                stdenv = arm64ec-w64-mingw32-build-clangNoLibcStdenv;
            }).overrideAttrs (prevAttrs: {
                RCFLAGS = "-I${final.mingw_w64_headers}/include";
            });
        });
        arm64ec-w64-mingw32-windows-pthreads = arm64ec-w64-mingw32-windows.pthreads;
        arm64ec-w64-mingw32-windows-mingw_w64 = arm64ec-w64-mingw32-windows.mingw_w64;
        arm64ec-w64-mingw32-build-bintools = arm64ec-w64-mingw32-build-llvm_21.bintools.override {
            stdenvNoCC = arm64ec-w64-mingw32-build-stdenvNoCC;
            libc = arm64ec-w64-mingw32-windows.mingw_w64;
        };
        arm64ec-w64-mingw32-compiler-rt-no-libc-combined = aarch64-w64-mingw32-build.runCommand "compiler-rt" {} ''
            ${arm64ec-w64-mingw32-build-llvm_21.bintools-unwrapped.out}/bin/arm64ec-w64-mingw32-llvm-lib -machine:arm64ec \
                -out:$out/lib/windows/libclang_rt.builtins-aarch64.a \
                ${arm64ec-w64-mingw32-compiler-rt-no-libc.out}/lib/windows/libclang_rt.builtins-arm64ec.a \
                ${aarch64-w64-mingw32-pkgs.llvmPackages_21.compiler-rt-no-libc.out}/lib/windows/libclang_rt.builtins-aarch64.a
        '';
        arm64ec-w64-mingw32-build-clangNoLibcxx = arm64ec-w64-mingw32-build-llvm_21.clangNoLibcxx.override {
            stdenvNoCC = arm64ec-w64-mingw32-build-stdenvNoCC;
            bintools = arm64ec-w64-mingw32-build-bintools;
            libc = arm64ec-w64-mingw32-build-bintools.libc;
        };
        arm64ec-w64-mingw32-libunwind = (aarch64-w64-mingw32-pkgs.llvmPackages_21.libunwind.override {
            stdenv = aarch64-w64-mingw32-build.overrideCC arm64ec-w64-mingw32-stdenv arm64ec-w64-mingw32-build-clangNoLibcxx;
        }).overrideAttrs (prev: {
            cmakeFlags = prev.cmakeFlags ++ [ "-DCMAKE_SYSTEM_PROCESSOR=arm64ec" ];
        });
        arm64ec-w64-mingw32-libcxx = aarch64-w64-mingw32-pkgs.llvmPackages_21.libcxx.override ({
            stdenv = aarch64-w64-mingw32-build.overrideCC arm64ec-w64-mingw32-stdenv arm64ec-w64-mingw32-build-clangNoLibcxx;
            libunwind = arm64ec-w64-mingw32-libunwind;
        });
        arm64ec-w64-mingw32-build-clangWithLibcAndBasicRtAndLibcxx = arm64ec-w64-mingw32-build-llvm_21.clangWithLibcAndBasicRtAndLibcxx.override {
            stdenvNoCC = arm64ec-w64-mingw32-build-stdenvNoCC;
            bintools = arm64ec-w64-mingw32-build-bintools;
            libc = arm64ec-w64-mingw32-build-bintools.libc;
        };
        arm64ec-w64-mingw32-compiler-rt-libc = (aarch64-w64-mingw32-pkgs.llvmPackages_21.compiler-rt-libc.override {
            stdenv = aarch64-w64-mingw32-build.overrideCC arm64ec-w64-mingw32-stdenv arm64ec-w64-mingw32-build-clangWithLibcAndBasicRtAndLibcxx;
        })
        .overrideAttrs (prevAttrs: {
            postInstall = prevAttrs.postInstall + ''
                arm64ec-w64-mingw32-llvm-lib -machine:arm64ec -out:$out/lib/windows/libclang_rt.builtins-aarch64.a \
                    $out/lib/windows/libclang_rt.builtins-arm64ec.a \
                    ${aarch64-w64-mingw32-pkgs.llvmPackages_21.compiler-rt-libc}/lib/windows/libclang_rt.builtins-aarch64.a
                rm $out/lib/windows/libclang_rt.builtins-arm64ec.a;
                ln -s $out/lib/windows/libclang_rt.builtins-aarch64.a $out/lib/windows/libclang_rt.builtins-arm64ec.a
            '';
        });
        arm64ec-w64-mingw32-build-clangUseLLVM = arm64ec-w64-mingw32-build-llvm_21.clangUseLLVM.override {
            stdenvNoCC = arm64ec-w64-mingw32-build-stdenvNoCC;
            bintools = arm64ec-w64-mingw32-build-bintools;
            libc = arm64ec-w64-mingw32-build-bintools.libc;
        };
        arm64ec-w64-mingw32-build-clangStdenv = aarch64-w64-mingw32-build.overrideCC arm64ec-w64-mingw32-stdenvNoCC arm64ec-w64-mingw32-build-clangUseLLVM;
        arm64ec-w64-mingw32-fex-lib = arm64ec-w64-mingw32-build-clangStdenv.mkDerivation (finalAttrs: {
            pname = "fex";
            version = "2509.1";
            src = fetchFromGitHub {
                owner = "FEX-Emu";
                repo = "FEX";
                tag = "FEX-${finalAttrs.version}";
                hash = "sha256-Mlch6MbrQmOgo+q1OIyflTYlrbH7qGqFbcI/8v2c+aQ=";
                leaveDotGit = true;
                postFetch = ''
                  cd $out
                  git reset
                  # Only fetch required submodules
                  git submodule update --init --depth 1
                  find . -name .git -print0 | xargs -0 rm -rf
                '';
              };

            nativeBuildInputs = [
                git
                nasm
                cmake
                ninja
                pkg-config
                (python3.withPackages ( pythonPackages:
                   with pythonPackages; [ setuptools ]
                ))
            ];
            buildInputs = [ arm64ec-w64-mingw32-windows.pthreads ];
            cmakeFlags = [
                (lib.cmakeFeature "MINGW_TRIPLE" "arm64ec-w64-mingw32")
                (lib.cmakeFeature "CMAKE_TOOLCHAIN_FILE" "Data/CMake/toolchain_mingw.cmake")
                (lib.cmakeBool "ENABLE_LTO" false)
                (lib.cmakeBool "BUILD_TESTS" false)
                (lib.cmakeBool "ENABLE_JEMALLOC_GLIBC_ALLOC" false)
            ];
        });
        arm64ec-w64-mingw32-dxvk = aarch64-w64-mingw32-pkgs.dxvk_2.override {
            stdenv = arm64ec-w64-mingw32-build-clangStdenv;
            windows = arm64ec-w64-mingw32-windows;
        };
        wine_overrideAttrs = prevAttrs: {
            src = fetchFromGitHub {
                owner = "AndreRH";
                repo = "wine";
                rev = "8af5bc31eb85ba63dd1434a588828c2d1ae71f3a";
                hash = "sha256-WcRca096W57fF0GRjGCq+mx9hf+XYqNzUAo1dyC32gU=";
            };
            meta.platforms = prevAttrs.meta.platforms ++ [ "aarch64-linux" ];
            configureFlags = (builtins.filter (flag: flag != "--enable-archs=x86_64,i386") prevAttrs.configureFlags) ++ [ "--enable-archs=arm64ec,aarch64 --with-mingw=clang" ];
            nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [
                arm64ec-w64-mingw32-build-clangUseLLVM
                aarch64-w64-mingw32-build.llvmPackages_21.clang
                llvmPackages_21.bintools
            ];
            postInstall = prevAttrs.postInstall + ''
                cp ${arm64ec-w64-mingw32-fex-lib}/lib/libarm64ecfex.dll $out/lib/wine/aarch64-windows/
                cp ${arm64ec-w64-mingw32-dxvk}/bin/*.dll $out/lib/wine/aarch64-windows/
            '';
        };
        wine = wineWow64Packages.unstableFull.overrideAttrs wine_overrideAttrs;
}
