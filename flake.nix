{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";
    home-manager.url = "github:nix-community/home-manager";
    plasma-manager.url = "github:nix-community/plasma-manager";
    agenix.url = "github:ryantm/agenix";
    nixvim.url = "github:nix-community/nixvim";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    nixosFor = host: system: nixpkgs.lib.nixosSystem {
      system = system;
      specialArgs = { inherit inputs; };
      modules = [
        modules/hardware.nix
        modules/agenix.nix
        modules/nixvim.nix
        modules/desktop.nix
        modules/home-manager.nix
        modules/base.nix
        hosts/${host}
        { networking.hostName = host; }
      ];
    };
  in {
    inherit inputs;
    nixosConfigurations = builtins.mapAttrs nixosFor {
      gurren = "x86_64-linux";
      giga = "x86_64-linux";
      pipa = "aarch64-linux";
    };
  };
}


# vim: set tabstop=8 softtabstop=2 shiftwidth=2 expandtab:

