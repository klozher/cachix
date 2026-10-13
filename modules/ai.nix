{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.klozher.ai;
in {
    options.klozher.ai = {
        enable = lib.mkEnableOption "Enable AI Tools";
    };
    config = lib.mkIf cfg.enable {
        services.searx = {
            enable = true;
            settings = {
                use_default_settings.engines.keep_only = [ "bing" "yandex" "baidu" ];
                server.bind_address = "127.0.0.1";
                server.port = 10100;
                server.secret_key = "not_secret_key";
                search.autocomplete = "bing";
                search.default_lang = "auto";
                search.safe_search = 0;
                search.formats = [ "html" "json" ];
                engines = [{
                    name = "bing";
                    disabled = false;
                    base_url = "https://cn.bing.com";
                    weight = "1.5";
                } {
                    name = "yandex";
                    disabled = false;
                    weight = "1.2";
                } {
                    name = "baidu";
                    disabled = true;
                }];
            };
        };
        home-manager.sharedModules = [({config, lib, pkgs, ...}: {
            programs.claude-code = {
                enable = true;
            };
            # pi-coding-agent
            programs.pi-coding-agent = {
                enable = true;
                configDir = "${config.xdg.configHome}/pi/agent";
                extraPackages = with pkgs; [ nodejs python3 ];
                appendSystem = ''
                    # CRITICAL TERMINAL CONSTRAINT
                    - You are strictly FORBIDDEN from using `sudo` or attempting to gain root privileges under any circumstances.
                    - If a command requires root/sudo access, you must immediately halt execution, explain the block to the user, and ask them to run it manually.
                    - Never chain `sudo` into multi-command strings (e.g., `cd /var && sudo rm ...`).

                    # ENVIRONMENT CONSTRAINTS: NIXOS
                    You are operating on a NixOS Linux environment.
                    - Traditional global package managers like 'apt', 'yum', 'pacman', 'brew', or 'npm install -g' DO NOT EXIST and will cause fatal shell crashes.
                    - The root filesystem is READ-ONLY. Do not attempt to modify global binaries in /bin, /sbin, or /usr/bin.
                    - If you need a package, tool, or CLI compiler that is missing, DO NOT try to install it. Instead, wrap your execution using the 'nix run nixpkgs#<package> -- <args>' pattern, or 'nix shell nixpkgs#<package> --command <command> <args>'.
                    - For building or running project-specific code environments, check for the presence of a 'flake.nix' or 'shell.nix' and execute within that context using 'nix develop' or 'nix-shell'.
                '';
                settings = {
                    packages = [
                        "npm:pi-web-access"
                        "npm:@gotgenes/pi-permission-system"
                    ];
                };
            };
            home.persistence."/persist".directories = [
                config.programs.pi-coding-agent.configDir
            ];
            age.secrets.piauth.path = "${config.programs.pi-coding-agent.configDir}/auth.json";
        })];
    };
}

