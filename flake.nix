{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    outputs = {self, nixpkgs, ...}:
    let
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        custom-pkgs = with pkgs.lib.attrsets; filterAttrs (n: v: isDerivation v) (pkgs.callPackage ./custom-pkgs.nix {});
    in {
        packages.aarch64-linux = custom-pkgs;
    };
}

