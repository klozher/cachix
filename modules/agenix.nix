{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.klozher.agenix;
in {
    imports = [ inputs.agenix.nixosModules.age ];
    options.klozher.agenix = {
        enable = lib.mkEnableOption "Enable agenix";
    };
    config = lib.mkIf cfg.enable {
        environment.systemPackages = [ inputs.agenix.packages."${pkgs.stdenv.hostPlatform.system}".agenix ];
        age.identityPaths = [
            "/persist/etc/ssh/ssh_host_rsa_key"
            "/persist/etc/ssh/ssh_host_ed25519_key"
        ];
        age.secrets = {
            passwd.file = ../secrets/passwd.age;
            aikey.file = ../secrets/aikey.age;
        };
        users.users.sice.hashedPasswordFile = config.age.secrets.passwd.path;
        home-manager.sharedModules = [
            inputs.agenix.homeManagerModules.default
            ({...}: {
                age.secrets = {
                    aikey.file = ../secrets/aikey.age;
                    zhipu.file = ../secrets/zhipu.age;
                };
            })
        ];
    };
}

