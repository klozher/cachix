{ config, pkgs, lib, inputs, ... }:
{
    environment.persistence."/persist" = {
        enable = true;
        hideMounts = true;
        directories = [
            "/etc/nixos"
            "/etc/NetworkManager/system-connections"
            "/var/log"
            "/var/lib/nixos"
            "/var/lib/alsa"
            "/var/lib/samba"
            "/var/lib/waydroid"
            "/var/lib/bluetooth"
            "/var/lib/libvirt"
        ];
        files = [
            "/etc/machine-id"
            "/etc/ssh/ssh_host_rsa_key"
            "/etc/ssh/ssh_host_rsa_key.pub"
            "/etc/ssh/ssh_host_ed25519_key"
            "/etc/ssh/ssh_host_ed25519_key.pub"
        ];
    };
}
