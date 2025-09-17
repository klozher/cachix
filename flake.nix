{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    outputs = {self, nixpkgs, ...}: {
        packages.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.callPackage ./custom-pkgs.nix {};
    };
}

