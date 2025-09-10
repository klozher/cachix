{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    outputs = {self, nixpkgs, ...}: {
        packages.aarch64-linux.wine = with nixpkgs.legacyPackages.aarch64-linux; wineWow64Packages.minimal.overrideAttrs
            (prevAttrs: {
                meta.platforms = prevAttrs.meta.platforms ++ [ "aarch64-linux" ];
                configureFlags = (builtins.filter (flag: flag != "--enable-archs=x86_64,i386") prevAttrs.configureFlags) ++ [ "--enable-archs=aarch64,i386" ];
                nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ pkgsCross.ucrtAarch64.buildPackages.clang_21 ];
            });
    };
}
