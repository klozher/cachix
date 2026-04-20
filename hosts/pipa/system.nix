{ config, pkgs, lib, inputs, ... }:
{
    networking.hostName = "pipa";
    services.displayManager = {
        autoLogin.enable = true;
        autoLogin.user = "sice";
    };
    virtualisation.waydroid.enable = true;
    boot.binfmt.registrations = {
        x86_64-linux = {
            magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00'';
            mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
            interpreter = "${pkgs.box64}/bin/box64";
        };
#        i386-linux = {
#            magicOrExtension = ''\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x03\x00'';
#            mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
#        };
    };
    programs = {
        firefox.enable = true;
    };
    environment.systemPackages = with pkgs; [
        mpv alsa-utils e2fsprogs
        android-tools unzip binutils
        qbittorrent krita #obsidian
    ];
}

