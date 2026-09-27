{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.klozher.obsidian;
in {
    options.klozher.obsidian = {
        enable = lib.mkEnableOption "Enable obsidian";
    };
    config = lib.mkIf cfg.enable {
        nixpkgs.overlays = [ inputs.obsidian-extensions.overlays.default ];
        home-manager.sharedModules = [({config, lib, pkgs, ...}: {
            programs.obsidian = {
                enable = true;
                vaults."Documents/notes".enable = true;
                vaults."Documents/japanese".enable = true;
                defaultSettings.app = {
                    legacyThirdPartyPlugins = true;
                };
                defaultSettings.communityPlugins = [{
                    enable = true;
                    pkg = pkgs.obsidianPlugins.remotely-save;
                    settings.readme = "The file contains sensitive info, so DO NOT take screenshot of, copy, or share it to anyone! It's also generated automatically, so do not edit it manually.";
                    settings.d = builtins.concatStringsSep "" [
"91nIiojIslWYtVmIs01W6IyclJXd0FWZG9mcQRWZsJWYuVmIsIiI6Iiblt2bUh2clJnZlJnIsAjOiMXT"
"l1WaURXQzVmcpBHeF5WZr9GVzNXZjNWYiwCM6IycN5WSzVmcpBHeF5WZr9GVzNXZjNWYiwiIiojIuV2a"
"vR1czV2YjFmI7pjIvJHciwSflNHbhZmOiUmepNFZy92YlJnIsU2csFmZ6IyZulGdulmcQVGbiFmblJCL"
"lNHbhZmOiUGbiFmblJye6IiclxWam9mcwJCLiQjNlNXYi1SZu9GbjJnI6ICZvhGdl1kbvlGdwlncj5WZ"
"iwSZzxWYmpjIyFmQzVHdhR3UlxWai9WTlxmYh5WZiwSZ1JHd6ISZslmRn5Wa0RXZTVGdhN2c1ZmYvJCL"
"iwWYu9Wa0NWZylGZpJmI6IibvlGdjVmcpR0Yul3ciwCM1ojIldWY05WZjJXZQlnZpR2bNR3YlR3byBnI"
"sICa09mYf5WYlx2YiojIyVGZs9mR5RHctVkbhVGbD9GV39GaiwiIyV2dl52XwVWZrJiOi42bpR3YBR3Y"
"pxmZu92YiwSZ1JHd6IyMWNmb5NVZzV1bUVWZydWYiwiItVGdzl3ciojIlJXZod1bUVGdlxWZkJCLlVnc"
"0pjIvZmbJJXYCNXd0FGdTVGbiFmblJCLdtlOiMHa0FGU39GbsFUes52biwSXbpjIzhGdhBVZy9mbnlmI"
"sETL6IibhhGVyV2ZyFGTlpXaTBXarNnIsU2csFmZ6IiQE9GVn9GbiwiIvRXdhJiOicmbhxmIsU2csFmZ"
"6IyctVGdJVmcvN2cyVGZuV1Yul3ciwSZ1JHd6IycrJXYtt2bvJ0Yul3ciwSZzxWYmpjIylGRnlmZu92Q"
"j5WezJCL1ojI5NmblJnc1NmbvNmIsUWdyRnOiEGdhRWY0VWThJHd4VEZh9GbwV1bUVWZydWYiwCMwATM"
"6Iyck52bjV2cpxGbp1kclRnZBVmdhNlbPNmb5NnIsADMwATM6Iyck52bjV2cpxGbp1kclRnZB5WdSRXa"
"ulmIsADMwADMzojIzRmbvNWZzlGbslWT5JXZ2Vkb1J1b0VXYiwiIvZmbpJiOiwWZ2VGTn9GTyJXdjJCL"
"iYXYkJWZ3JiOiUGc5RVZjlmdyV2ciwiIiojIkJ3b3N3chBnIs0nIldWYy9GdzJ2bsJWZyVnehJiOiQmb"
"ptmIsUjOik3YuVmcyV3Yu92QzRnchBnIsU2csFmZ6ICdjVmai9kclRGbvZUZ0Fmcl5WZnJCLiIiOigXa"
"mVmcQVGdv1WZyJCLiIiOiUWbh5kcl5WahRnbvNmIsIiI6ICbyV1chNlcl5WahRnbvNmI7pjIldWYy9Gd"
"zJ2bsJWZyVnehJCL9Jicm92brJiOiQmbptmIsIiI6ICRJRnb19WbiwiI0VmbuInZv92auAHch9yL6MHc"
"0RHaiojIpBXYiwiIiojIlB3bjNnIsAjOiMXTl1WaURXQkVGdlxWZEVmQkxWdvh2UzxWYpRnblRWZyNmI"
"sIiI6IicpRUZzFmQlR3btVmciwiIiojIuV2avRFazVmcmVmciwCM6IycNVWbpRFdBNXZylGc4Vkblt2b"
"UN3clN2YhJCLwojIz1kbJNXZylGc4Vkblt2bUN3clN2YhJCLiIiOi4WZr9GVzNXZjNWYisnOiInZv92a"
"iwSfis2cpRGelRmbhlnI6ICZul2aiwiIiojIlB3bjNnIsIiI6Iiblt2bUh2clJnZlJnIsAjOiMXTl1Wa"
"URXQzVmcpBHeF5WZr9GVzNXZjNWYiwCM6IycN5WSzVmcpBHeF5WZr9GVzNXZjNWYiwiIiojIuV2avR1c"
"zV2YjFmI7pjIrNXakhXZk5WY5JCL9JCZ19GbjBnI6ICZul2aiwiIwl2azJiOiUGbpZUe0BXblJCLwojI"
"z1UZtlGV0FEZlRXZsVGRlJEZsV3boN1csFWa05WZkVmcjJCLyojIklmbvlGdhN2bsJCLi02bj5CZ19Gb"
"jBnLpBXYlJiOiUWbh5Gdz9GaiwiIiojIuV2avR1czV2YjFmI7pjIkV3bsNGciwSfig3biJiOiQmbptmI"
"sAjOiMXTl1WaURXQkVGdlxWZEVmQkxWdvh2UzxWYpRnblRWZyNmIsAjOiMXTl1WaURXQzVmcpBHeF5WZ"
"r9GVzNXZjNWYiwCM6IycN5WSzVmcpBHeF5WZr9GVzNXZjNWYiwiIiojIuV2avRFazVmcmVmciwiIiojI"
"uV2avR1czV2YjFmI7pjI49mYiwSfiUmdpJHZlx2Zv92ZiojIk5WarJCLiUGbpZmLlZXayR2LoRXdh9Sb"
"vNmLzlGchVGbn92bn5yd3d3LvozcwRHdoJiOiUGcvN2ciwCM6IycNVWbpRFdBRWZ0VGblRUZCRGb19Ga"
"TNHbhlGduVGZlJ3YiwCM6IycNVWbpRFdBNXZylGc4Vkblt2bUN3clN2YhJCLwojIz1kbJNXZylGc4Vkb"
"lt2bUN3clN2YhJCLiIiOi4WZr9GVoNXZyZWZyJCLiIiOi4WZr9GVzNXZjNWYisnOiUmdpJHZlx2Zv92Z"
"iwSfiIiOiIXaEV2chJUZ09WblJnIsIiI6ICZy92dzNXYwJCLiIiOiUWbh5mclNXdiwiIiojIzNXZyRGZ"
"hJye6IycpRmYldnIs0nIsxWdmVmdpJHZl52biojIk5WarJCLiAXarNnI6ISZslmR5RHctVmIsAjOiUWb"
"pRFdBRWZ0VGblRUZCRGb19GaTNHbhlGduVGZlJ3YiwiIiojIl1WYuJXZzVnIsIiI6IyaulGThRHblRmI"
"sAjOiUWbpRFdBNXZylGc4Vkblt2bUN3clN2YhJCLwojIzRmbvNWZT5WSzVmcpBHeF5WZr9GVzNXZjNWY"
"iwiIiojIuV2avRFazVmcmVmciwiIu9Wbt92Yv02bj5SZulGbu9Gdm92cvJ3Yp1mLul2Zvx2LvozcwRHd"
"oJiOikHdpJ3boRXdhJCLiYDM4YmZwYGNjF2Nk1iN3MTOtMWZiRTLyYWYw0yYxMmZ5IzNzIiOiQUS05WZ"
"px2YiwiIiojIuV2avR1czV2YjFmI7pjIsxWdmVmdpJHZl52biwSfiIiOiIXaEV2chJUZ09WblJnIsISZ"
"2lmckVmbvJiOiQmbptmIsICcpt2ciojIlxWaGlHdw1WZiwCM6ISZtlGV0FEZlRXZsVGRlJEZsV3boN1c"
"sFWa05WZkVmcjJCLiIiOiUWbh5mclNXdiwiIiojIr5WaMFGdsVGZiwCM6ISZtlGV0F0clJXawhXRuV2a"
"vR1czV2YjFmIsAjOiMHZu92YlNlbJNXZylGc4Vkblt2bUN3clN2YhJCLiIiOi4WZr9GVoNXZyZWZyJCL"
"i42bt12bj9SbvNmLl5Was52b0Z2bz9mcjlWbu4Wan9Gbv8iOzBHd0hmI6ISe0lmcvhGd1FmIsIiNwgjZ"
"mBjZ0MWY3QWL2czM50yYlJGNtIjZhBTLjFzYmljM3MjI6ICRJRnbllGbjJCLiIiOi4WZr9GVzNXZjNWY"
"isnOiUmdpJHZl52biwSfiIiOiIXaEV2chJUZ09WblJnIsAjOiUWbpRFdBRWZ0VGblRUZCRGb19GaTNHb"
"hlGduVGZlJ3YiwiIiojIl1WYuJXZzVnIsIiI6ICRJRnb192YjFmIsAjOiUWbpRFdBNXZylGc4Vkblt2b"
"UN3clN2YhJCLwojIzRmbvNWZT5WSzVmcpBHeF5WZr9GVzNXZjNWYiwiIiojIuV2avRFazVmcmVmciwiI"
"mpne0MWbytmZvRjd4dXdiojIElEduVWasNmIsIiI6Iiblt2bUN3clN2YhJye6ICevJGcvJHZiwSfiIiO"
"iMnclRWYlhUbvR3c1NmIsIiI6IicpRUZzFmQlR3btVmciwiIx8FbhVnbh1mI6ICa0BXZkJCLlVnc0pjI"
"lZXazJXdjVmUsFWduFWbiwiIjl2chJmI6ISZwlHVoRXdhJCLiE2c4onNuhGN30WOjRzczFmI6ICZy92d"
"zNXYwJCLi02bj5CbpFWb09GaAdTOpVGb19GaiojIl1WYuJXZzVnIsIyL2FGZv02bj5ib1l3b1dmbhlma"
"uYXYk9yL6MHc0RHaiojIzNXZyRGZhJye6IidhRmYldnIs0XZzxWYmpjI0NWZqJ2TyVGZs9mRlRXYyVmb"
"ldmIsIiI6ICbyVlbnl2Uv5Ue49mcQV2cyVmdlJnIsU2csFmZ6ISZtlGVNVGdhJXdjNWQlNXdiwiIiojI"
"4lmZlJHUlR3btVmciwSZzxWYmpjIlxWe0NFa0FGUlNmcvZmIsAjM6ISej5WZyJXdj52bDNHdyFGciwSZ"
"1JHd6ISesxWYj9GTzJ3bDN3chBXeiJCLiIiOiUWbh5Edlt2Y1J0MzJCLiIiOikXZLN3clN2YBRXZyNWZ"
"TNzciwiIiojIElUelt0czV2YjF0MzJCLiIiOi42bpdWZSNzciwiIiojI05WavBHZuV0MzJye6IyMzJye"
                    ];
                }];
            };
        })];
    };
}

