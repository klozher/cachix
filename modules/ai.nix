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
            home.persistence."/persist".directories = [
                "${config.xdg.configHome}/pi/agent"
            ];
            programs.claude-code = {
                enable = true;
            };
            # pi-coding-agent
            age.secrets.piauth.path = "${config.programs.pi-coding-agent.configDir}/auth.json";
            programs.pi-coding-agent = {
                enable = true;
                package = let
                    shellArgs = args: lib.concatStringsSep " " (map (arg: "\"${arg}\"") args);
                    bwrapArgs = mounts: lib.concatMap ( mount:
                        if mount.type == "rw" then [ "--bind-try" mount.path mount.path ]
                        else if mount.type == "ro" then [ "--ro-bind-try" mount.path mount.path ]
                        else if mount.type == "dev" then [ "--dev-bind" mount.path mount.path ]
                        else if mount.type == "tmpfs" then [ "--dir" mount.path "--tmpfs" mount.path ]
                        else if mount.type == "null" then [ "--ro-bind-try" "/dev/null" mount.path ]
                        else throw "Unknown mount type"
                    ) mounts;
                    # the mount order is intentional
                    mountpoints = [{
                        path = "/";
                        type = "rw";
                    } {
                        path = "/dev";
                        type = "dev";
                    } {
                        path = "/etc";
                        type = "ro";
                    } {
                        path = "/home";
                        type = "ro";
                    } {
                        path = "${config.programs.pi-coding-agent.configDir}";
                        type = "rw";
                    } {
                        path = "$PWD";
                        type = "rw";
                    } {
                        path = "$PWD/.git";
                        type = "ro";
                    } {
                        path = "$PWD/.env";
                        type = "null";
                    } {
                        path = "/persist";
                        type = "tmpfs";
                    } {
                        path = "/etc/ssh";
                        type = "tmpfs";
                    } {
                        path = "${config.home.homeDirectory}/.cache";
                        type = "tmpfs";
                    } {
                        path = "${config.home.homeDirectory}/.ssh";
                        type = "tmpfs";
                    } {
                        path = "${config.xdg.configHome}/zsh";
                        type = "tmpfs";
                    } {
                        path = "${config.xdg.configHome}/mozilla";
                        type = "tmpfs";
                    }];
                    in pkgs.writeShellScriptBin "pi" ''
                        export NPM_CONFIG_CACHE=/tmp/.npm-cache
                        exec ${lib.getExe pkgs.bubblewrap} \
                        ${shellArgs (bwrapArgs mountpoints)} \
                        -- ${lib.getExe pkgs.pi-coding-agent} "$@"
                '';
                configDir = "${config.xdg.configHome}/pi/agent";
                extraPackages = with pkgs; [ nodejs python3 ];
                appendSystem = ''
                    # CRITICAL TERMINAL CONSTRAINTS
                    - **ABSOLUTE NO SUDO:** Strictly forbidden from using `sudo` or `su` under any circumstances. If a task fails due to permissions, halt immediately and report it to the user.
                    - **NON-INTERACTIVE ONLY:** All commands MUST be fully automated and non-interactive. Always append silent/auto-confirm flags (e.g., `-y`, `--yes`, `--force`) to prevent hanging.
                    # ENVIRONMENT CONSTRAINTS: NIXOS FLAKES
                    - **IMMUTABLE SYSTEM:** You are on NixOS. The root filesystem is read-only. Never attempt to write to `/bin`, `/sbin`, `/usr`, or use external package managers.
                    - **FLAKE-FIRST TOOL RUNNING:** If a CLI tool is missing, execute it on-the-fly using Flake syntax. You MUST use the double-dash argument separator explicitly: 
                      Syntax: nix run nixpkgs#<package> -- <args>  (Example: nix run nixpkgs#curl -- -I google.com)
                    - **UNFREE EXEMPTION:** If running an unfree/proprietary package via Nix, you MUST prepend the environment variable: `NIXPKGS_ALLOW_UNFREE=1 nix run ...`
                    - **PROJECT CONTEXT:** Prioritize modern `nix develop` over legacy `nix-shell` if a `flake.nix` is present in the working directory.
                '';
                settings.packages = [
                    "npm:pi-web-access"
                ];
            };
        })];
    };
}

