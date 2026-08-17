{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.klozher.desktop;
in {
    options.klozher.desktop = {
        enable = lib.mkEnableOption "Enable desktop";
        desktop = lib.mkOption {
            type = lib.types.enum [ "plasma" "gnome" "hyprland" ];
        };
    };
    imports = [
        ./input-method.nix
        ./plasma.nix
        ./gnome.nix
        ./hyprland.nix
    ];
    config = lib.mkIf cfg.enable {
        fonts.packages = [ pkgs.nerd-fonts.symbols-only ];
        networking.networkmanager.enable = true;
        programs.kdeconnect.enable = true;
        environment.systemPackages = with pkgs; [
            wl-clipboard
            xclip
        ];
    };
}

