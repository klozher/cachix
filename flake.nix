{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/8eb28adfa3dc4de28e792e3bf49fcf9007ca8ac9";
    };
    outputs = {self, nixpkgs, ...}: {
        packages.aarch64-linux.wine = with nixpkgs.legacyPackages.aarch64-linux; wineWow64Packages.minimal.overrideAttrs
            (prevAttrs: {
                meta.platforms = prevAttrs.meta.platforms ++ [ "aarch64-linux" ];
                configureFlags = (builtins.filter (flag: flag != "--enable-archs=x86_64,i386") prevAttrs.configureFlags) ++ [ "--enable-archs=arm64ec,aarch64,i386" "--with-mingw=clang" ];
                nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ pkgsCross.ucrtAarch64.buildPackages.clang_21 ];
            });
    };
}
