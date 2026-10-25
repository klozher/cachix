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
            programs.zsh.shellAliases = {
                "env-zhipu" = "/usr/bin/env $(< ${config.age.secrets."aikeys.env".path})";
                "claude-zhipu" = "env-zhipu claude";
            };
            programs.claude-code = {
                enable = true;
            };
            # pi-coding-agent
            programs.pi-coding-agent = {
                enable = true;
                package = pkgs.writeShellScriptBin "pi" ''
                        set -a
                        source ${config.age.secrets."aikeys.env".path}
                        NPM_CONFIG_CACHE=/tmp/.npm-cache
                        set +a

                        ARGS=()

                        function bind_rw {
                            [[ -e "$1" ]] && ARGS+=("--bind" "$1" "$1")
                        }

                        function bind_ro {
                            [[ -e "$1" ]] && ARGS+=("--ro-bind" "$1" "$1")
                        }

                        function bind_dev {
                            [[ -e "$1" ]] && ARGS+=("--dev-bind" "$1" "$1")
                        }

                        function bind_shadow {
                            [[ -d "$1" ]] && ARGS+=("--tmpfs" "$1")
                            [[ -f "$1" ]] && ARGS+=("--ro-bind" "/dev/null" "$1")
                        }

                        function new_dir {
                            ARGS+=("--dir" "$1")
                        }

                        bind_rw "/"
                        bind_dev "/dev"
                        bind_ro "/etc"
                        bind_shadow "/persist"
                        bind_shadow "/etc/ssh"

                        bind_shadow "/home"
                        new_dir "${config.programs.pi-coding-agent.configDir}"
                        bind_rw "${config.programs.pi-coding-agent.configDir}"
                        new_dir "$PWD"
                        bind_rw "$PWD"
                        bind_ro "$PWD/.git"
                        bind_shadow "$PWD/.env"

                        exec ${lib.getExe pkgs.bubblewrap} "''${ARGS[@]}" \
                        -- ${lib.getExe pkgs.pi-coding-agent} "$@"
                '';
                configDir = "${config.xdg.configHome}/pi/agent";
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
                extraPackages = with pkgs; [
                    nodejs
                    python3
                ];
                settings = {
                    extensions = [
                    ];
                    packages = [
                        "npm:pi-web-access"
                        "npm:@narumitw/pi-usage"
                        "npm:pi-zai-mcp"
                        "npm:pi-subagents"
                    ];
                };
            };
        })];
    };
}

