{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    outputs = {self, nixpkgs, ...}:
    let
        pkgs = import nixpkgs {
            system = "aarch64-linux";
            config.allowUnfree = true;
            config.allowUnsupportedSystem = true;
        };
        custom-pkgs = with pkgs.lib.attrsets; filterAttrs (n: v: isDerivation v) (pkgs.callPackage ./custom-pkgs.nix {});
    in {
        packages.aarch64-linux = custom-pkgs;
    };
}

