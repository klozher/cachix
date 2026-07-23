{ config, pkgs, lib, inputs, ... }:
{
    imports = [ ./hardware.nix ];
    klozher.agenix.enable = true;
    klozher.desktop.enable = true;
    klozher.desktop.desktop = "gnome";
    klozher.neovim.enable = true;
    klozher.home-manager.enable = true;
    klozher.home-manager.users.sice = import ./home.nix;

    virtualisation.waydroid.enable = true;
    services.tlp.enable = true;
    services.tlp.pd.enable = true;
    services.power-profiles-daemon.enable = false;

    environment.sessionVariables = {
        XDG_DATA_DIRS = [ "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}" ];
    };
}

