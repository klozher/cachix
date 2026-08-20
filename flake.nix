{
    description = "A very basic flake";
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
        systems.url = "github:nix-systems/default-linux";
        home-manager.url = "github:nix-community/home-manager";
        impermanence.url = "github:nix-community/impermanence";
        plasma-manager.url = "github:nix-community/plasma-manager";
        agenix.url = "github:ryantm/agenix";
        nixvim.url = "github:nix-community/nixvim";
        nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
    };

    outputs = { self, nixpkgs, flake-parts, systems, ... }@inputs:
        flake-parts.lib.mkFlake { inherit inputs; } {
            systems = import systems;
            perSystem = { config, self', inputs', pkgs, system, ... }: {
                packages = import ./packages { inherit pkgs; };
            };
            flake = let
                nixosFor = host: system: nixpkgs.lib.nixosSystem {
                    system = system;
                    specialArgs = { inherit inputs; };
                    modules = [
                        modules/base.nix
                        modules/home-manager.nix
                        modules/state.nix
                        modules/zsh.nix
                        modules/hardware.nix
                        modules/persist.nix
                        modules/agenix.nix
                        modules/nixvim.nix
                        modules/network.nix
                        modules/desktop
                        hosts/${host}
                        {
                            networking.hostName = host;
                            nixpkgs.overlays = [ (final: prev: self.packages.${system}) ];
                        }
                    ];
                };
            in {
                nixosConfigurations = builtins.mapAttrs nixosFor {
                    gurren = "x86_64-linux";
                    lagann = "x86_64-linux";
                    t50 = "x86_64-linux";
                    giga = "x86_64-linux";
                    pipa = "aarch64-linux";
                };
            };
        };
}



