{ config, pkgs, lib, inputs, ... }:
{
    services.openssh.enable = true;
    services.openssh.startWhenNeeded = true;
    services.openssh.settings.PasswordAuthentication = false;

    services.resolved.enable = true;

    networking.nftables.enable = true;

    networking.firewall = {
        allowedUDPPorts = [ 5353 ];
    };
}

