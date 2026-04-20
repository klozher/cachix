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

  outputs = { self, nixpkgs, agenix, impermanence, home-manager, nixvim, nixpkgs-xr, ... }@inputs:
  let
    nixosFor = host: config: nixpkgs.lib.nixosSystem {
      system = config.system;
      specialArgs = { inherit inputs; };
      modules = [
        agenix.nixosModules.age modules/agenix.nix
        nixvim.nixosModules.nixvim modules/nixvim.nix
        impermanence.nixosModules.impermanence modules/persist.nix
        home-manager.nixosModules.home-manager
        #nixpkgs-xr.nixosModules.nixpkgs-xr
        modules/base.nix
        hosts/${host}/hardware.nix hosts/${host}/system.nix
      ] ++ config.modules;
    };
  in {
    inherit inputs;
    nixosConfigurations = builtins.mapAttrs nixosFor {
      gurren = {
        system = "x86_64-linux";
        modules = [modules/kde.nix];
      };
      giga = {
        system = "x86_64-linux";
        modules = [];
      };
      pipa = {
        system = "aarch64-linux";
        modules = [modules/gnome.nix];
      };
      pipa-live = {
        system = "aarch64-linux";
        modules = [];
      };
    };
  };
}


# vim: set tabstop=8 softtabstop=2 shiftwidth=2 expandtab:

