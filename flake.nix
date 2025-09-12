{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    outputs = {self, nixpkgs, ...}:
    let
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        callPackage = pkg: args:
            let pkgargs = builtins.functionArgs (import pkg);
                origin = pkgs.callPackage pkg args;
                override = ((pkgs.lib.optionalAttrs (pkgargs ? "callPackage") {
                    callPackage = callPackage;
                }) // (pkgs.lib.optionalAttrs (pkgargs ? "stdenv") {
                    stdenv = nixpkgs.legacyPackages.aarch64-linux.clangStdenv;
                }));
            in  origin.override override
        ;
        wine_override =  {
            callPackage = callPackage;
            stdenv = nixpkgs.legacyPackages.aarch64-linux.clangStdenv;
        };
        wine_overrideAttrs = with nixpkgs.legacyPackages.aarch64-linux; prevAttrs: {
            meta.platforms = prevAttrs.meta.platforms ++ [ "aarch64-linux" ];
            configureFlags = (builtins.filter (flag: flag != "--enable-archs=x86_64,i386") prevAttrs.configureFlags) ++ [ "--enable-archs=aarch64,i386" ];
            nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ pkgsCross.ucrtAarch64.buildPackages.clang_21 ];
        };
        wine = (nixpkgs.legacyPackages.aarch64-linux.wineWow64Packages.minimal.override wine_override).overrideAttrs wine_overrideAttrs;
    in {
        packages.aarch64-linux.wine = wine;
    };
}

