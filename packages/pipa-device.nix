{symlinkJoin, alsa-ucm-conf, pmports}:
symlinkJoin {
    name = "pipa-device";
    paths = [ alsa-ucm-conf ];
    postBuild = ''
        device_xiaomi_pipa="${pmports}/device/testing/device-xiaomi-pipa"
        install -Dm644 "$device_xiaomi_pipa/81-libssc-xiaomi-pipa.rules" -t "$out/lib/udev/rules.d/"
        install -Dm644 "$device_xiaomi_pipa/pipa.conf" -t "$out/share/alsa/ucm2/Xiaomi/pipa/"
        install -Dm644 "$device_xiaomi_pipa/HiFi.conf" -t "$out/share/alsa/ucm2/Xiaomi/pipa/"
        ln -s "../../Xiaomi/pipa/pipa.conf" "$out/share/alsa/ucm2/conf.d/sm8250/xiaomi-XiaomiPad6.conf"
        install -Dm644 "$device_xiaomi_pipa/local-overrides.quirks" -t "$out/etc/libinput/"
    '';
}

