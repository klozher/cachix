{ config, pkgs, lib, inputs, ... }:
{
    imports = [ ./hardware.nix ];
    klozher.agenix.enable = true;
    klozher.desktop.enable = true;
    klozher.desktop.desktop = "plasma";
    klozher.neovim.enable = true;
    klozher.home-manager.enable = true;
    klozher.home-manager.users.sice = import ./home.nix;

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    boot.kernelModules = ["ntsync"];
    virtualisation.libvirtd.enable = true;
    programs = {
        steam = {
            enable = true;
            extraPackages = with pkgs; [ gamescope mangohud ];
            extraCompatPackages = with pkgs; [ proton-ge-bin ];
        };
        clash-verge.enable = true;
        clash-verge.tunMode = true;
        clash-verge.serviceMode = true;
        virt-manager.enable = true;
    };
    networking.firewall = {
        enable = false;
        allowedTCPPorts = [ 3389 10030 ];
        allowedUDPPorts = [ 3389 10030 ];
    };
    services.scx.enable = true;
    services.scx.scheduler = "scx_lavd";
    services.input-remapper.enable = true;

    #    services.wivrn = {
    #        enable = true;
    #        openFirewall = true;
    #
    #        # Write information to /etc/xdg/openxr/1/active_runtime.json, VR applications
    #        # will automatically read this and work with WiVRn (Note: This does not currently
    #        # apply for games run in Valve's Proton)
    #          defaultRuntime = true;
    #
    #        # Run WiVRn as a systemd service on startup
    #        autoStart = true;
    #
    #        steam.importOXRRuntimes = true;
    #        highPriority = true;
    #
    #        # If you're running this with an nVidia GPU and want to use GPU Encoding (and don't otherwise have CUDA enabled system wide), you need to override the cudaSupport variable.
    #        #package = (pkgs.wivrn.override { cudaSupport = true; });
    #
    #        # You should use the default configuration (which is no configuration), as that works the best out of the box.
    #        # However, if you need to configure something see https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md for configuration options and https://mynixos.com/nixpkgs/option/services.wivrn.config.json for an example configuration.
    #    };
    services.samba = {
        enable = true;
        openFirewall = true;
        usershares.enable = true;
    };
    environment.variables = {
        #ENABLE_HDR_WSI = "1";
        #KWIN_WAYLAND_SUPPORT_XX_PIP_V1 = "1";
    };
    environment.systemPackages = with pkgs; [
        #vulkan-hdr-layer-kwin6
        #android-tools
    ];
    programs.cdemu.enable = true;
}

