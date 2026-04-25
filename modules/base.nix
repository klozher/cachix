{ config, pkgs, lib, inputs, ... }:
{
    system.stateVersion = "25.11";
    nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        substituters = lib.mkForce [ "https://mirror.sjtu.edu.cn/nix-channels/store" ];
        extra-substituters = [ "https://klozher.cachix.org" ];
        extra-trusted-public-keys = ["klozher.cachix.org-1:ohD7Cqxgjj2vLp4m+5vW4x4TVn0C2LVk6qeCZ7faEm8="];
        flake-registry = "";
    };
    nix.registry = {
        nixpkgs.flake = inputs.nixpkgs;
        home-manager.flake = inputs.home-manager;
    };
    nixpkgs.config.allowUnfree= true;
    nixpkgs.config.allowUnsupportedSystem = true;

    services.openssh.enable = true;
    services.openssh.startWhenNeeded = true;
    services.openssh.settings.PasswordAuthentication = false;

    services.resolved.enable = true;

    time.timeZone = "Asia/Shanghai";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocales = [ "zh_CN.UTF-8/UTF-8" ];

    users.mutableUsers = false;
    users.users.sice = {
        uid = 1000;
        createHome = true;
        isNormalUser = true;
        extraGroups = [ "wheel" "samba" "libvirtd" "cdrom"];
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPPr8P8HoWx5U16EvZZ6QdlxnnZ0QYBg1UFO8wr9pwTs sice@gurren"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0bzqib802Y+PQ0ss0irr4dFE/Plpns8pMhKnfgAK04 sice@t50"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOPtHsNZjivWUit3CWaoM1Z/36zg1BKeJhv5pufVzmIP sice@pipa"
        ];
    };

    programs = {
        nix-ld.enable = true;
        zsh = {
            enable = true;
            histSize = 10000;
            enableCompletion = true;
            autosuggestions.enable = true;
            syntaxHighlighting.enable = true;
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
    ];
}

