{ config, pkgs, lib, inputs, ... }:
{
    services.openssh.enable = true;
    services.openssh.startWhenNeeded = true;
    services.openssh.settings.PasswordAuthentication = false;

    services.resolved.enable = true;

    networking.nftables.enable = true;

    # TODO: disable for now since router not work with ipv6
    networking.enableIPv6 = false;

    networking.firewall = {
        allowedUDPPorts = [ 5353 ];
        allowedTCPPortRanges = [{
            from = 1716;
            to = 1746;
        }];
        allowedUDPPortRanges = [{
            from = 1716;
            to = 1746;
        }];
    };
}

