{ config, lib, pkgs, inputs, ... }:
{
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager.useGlobalPkgs = true;
    home-manager.extraSpecialArgs = { osConfig = config; };
    home-manager.sharedModules = [
    ];
}

