{ config, pkgs, lib, inputs, ... }:
{
    nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        substituters = [
            "https://mirrors.ustc.edu.cn/nix-channels/store?priority=30"
            "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=35"
            # cache.nixos.org
            "https://nix-community.cachix.org?priority=41"
            "https://klozher.cachix.org?priority=50"
        ];
        trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "klozher.cachix.org-1:ohD7Cqxgjj2vLp4m+5vW4x4TVn0C2LVk6qeCZ7faEm8="
        ];
        flake-registry = "";
    };
    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
    };
    nix.registry = lib.mapAttrs (name: value: { flake = value; }) inputs;
    system.extraDependencies = let
        collectFlakeInputs = input: [ input ] ++ builtins.concatMap collectFlakeInputs (builtins.attrValues (input.inputs or {}));
    in builtins.concatMap collectFlakeInputs (builtins.attrValues inputs);
    nixpkgs.config.allowUnfree= true;

    services.openssh.enable = true;
    services.openssh.startWhenNeeded = true;
    services.openssh.settings.PasswordAuthentication = false;

    services.resolved.enable = true;
    networking.nftables.enable = true;

    time.timeZone = "Asia/Shanghai";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocales = [ "zh_CN.UTF-8/UTF-8" ];

    users.mutableUsers = false;
    users.users.sice = {
        uid = 1000;
        linger = true;
        createHome = true;
        isNormalUser = true;
        extraGroups = [ "wheel" "samba" "libvirtd" "cdrom" "input" "networkmanager" ];
        openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPPr8P8HoWx5U16EvZZ6QdlxnnZ0QYBg1UFO8wr9pwTs sice@gurren"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0bzqib802Y+PQ0ss0irr4dFE/Plpns8pMhKnfgAK04 sice@t50"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOPtHsNZjivWUit3CWaoM1Z/36zg1BKeJhv5pufVzmIP sice@pipa"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7eR3TMICXrbCIoUtzHPOvSFu/iKvKMQThfS9+pj5VX sice@giga"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJV2gos20uFOdj3c7WEi7w80/x6+yezuQPo1o+MaF1J6 sice@lagann"
        ];
    };

    programs = {
        nix-ld.enable = true;
        git = {
            enable = true;
        };
    };

    environment.systemPackages = with pkgs; [
        home-manager
        lm_sensors
        pciutils
        usbutils
        eza
        file
        unzip
        nfs-utils
        e2fsprogs
        unar
        lsof
        atop
        android-tools
        binutils
    ];
}

