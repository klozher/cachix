{ config, pkgs, lib, inputs, ... }:
{
    environment.systemPackages = [ inputs.agenix.packages."${pkgs.system}".agenix ];
    age.identityPaths = [
        "/persist/etc/ssh/ssh_host_rsa_key"
        "/persist/etc/ssh/ssh_host_ed25519_key"
    ];
    age.secrets = {
        passwd.file = ./secrets/passwd.age;
    };
}
