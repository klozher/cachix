{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.klozher.i18n;
in {
    options.klozher.i18n = {
        enable = lib.mkEnableOption "Enable i18n support";
    };
    config = lib.mkIf cfg.enable {
        i18n = {
            defaultLocale = "en_US.UTF-8";
            extraLocales = [
                "zh_CN.UTF-8/UTF-8"
                "zh_CN.GB18030/GB18030"
                "zh_CN.GBK/GBK"
                "ja_JP.UTF-8/UTF-8"
                "ja_JP.EUC-JP/EUC-JP"
            ];
            inputMethod = {
                enable = true;
                enableGtk2 = true;
                enableGtk3 = true;
                type = "fcitx5";
                fcitx5 = {
                    waylandFrontend = true;
                    addons = with pkgs; [
                        qt6Packages.fcitx5-chinese-addons
                        fcitx5-mozc-ut
                        fcitx5-pinyin-zhwiki
                        fcitx5-pinyin-moegirl
                    ];
                    settings.inputMethod = {
                        "GroupOrder"."0" = "Default";
                        "Groups/0" = {
                            "Name" = "Default";
                            "Default Layout" = "us";
                            "DefaultIM" = "shuangpin";
                        };
                        "Groups/0/Items/0"."Name" = "keyboard-us";
                        "Groups/0/Items/1"."Name" = "shuangpin";
                        "Groups/0/Items/2"."Name" = "mozc";
                    };
                    settings.addons.pinyin.globalSection = {
                        ShuangpinProfile = "Xiaohe";
                    };
                };
            };
        };
    };
}

