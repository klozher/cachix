{ config, pkgs, lib, inputs, ... }:
{
    # use u-boot and systemd-boot instead of a custom script writing boot img to boot_a
    # flash u-boot to boot_a, modify gpt to mark cust as efi, mkfs.fat cust, mount cust on /boot
    # enable systemd-boot, config hardware.deviceTree, enable fwupd to upgrade u-boot
    boot.loader = {
        timeout = 0;
        systemd-boot.enable = true;
    };

    boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-pipa;
    hardware.deviceTree = {
        enable = true;
        name = "qcom/sm8250-xiaomi-pipa-csot.dtb";
    };
    hardware.firmware = [ pkgs.linux-firmware pkgs.pipa-firmware ];
    boot.initrd = {
        systemd.enable = true;
        availableKernelModules = [
            # bluetooth and camera only work in real rootfs
            #"hci_uart"
            #"qcom_camss"
            #"qcom_q6v5_pas"

            "apr"
            "bq25980_charger"
            "camcc_sm8250"
            "dm_cache_smq"
            "fastrpc"
            "fsa4480"
            "gpi"
            "gpio_keys_polled"
            "i2c_qcom_cci"
            "i2c_qcom_geni"
            "icc_bwmon"
            "icc_osm_l3"
            "ktz8866"
            "lattice_sysconfig_spi"
            "leds_qcom_flash"
            "leds_qcom_lpg"
            "llcc_qcom"
            "lpass_gfm_sm8250"
            "msm"
            "nanosic_803"
            "nt36523_ts"
            "nu1665"
            "ov13b10"
            "panel_novatek_nt36532"
            "pci_pwrctrl_pwrseq"
            "phy_qcom_qmp_combo"
            "phy_qcom_qmp_pcie"
            "phy_qcom_qmp_ufs"
            "phy_qcom_qmp_usb"
            "phy_qcom_qmp_usb_legacy"
            "phy_qcom_snps_femto_v2"
            "pinctrl_sm8250_lpass_lpi"
            "pwrseq_qcom_wcn"
            "q6adm"
            "q6afe"
            "q6afe_clocks"
            "q6afe_dai"
            "q6asm"
            "q6asm_dai"
            "q6core"
            "q6routing"
            "qcom_fg"
            "qcom_pmic_tcpm"
            "qcom_pon"
            "qcom_refgen_regulator"
            "qcom_rng"
            "qcom_spmi_adc5"
            "qcom_spmi_adc_tm5"
            "qcom_spmi_temp_alarm"
            "qcom_stats"
            "qcom_usb_vbus_regulator"
            "qcom_wdt"
            "qcom_wled"
            "qcomsmempart"
            "qcrypto"
            #"ramoops"
            "rcpufreq_dt"
            "rtc_pm8xxx"
            "sg2044_topsys"
            "snd_soc_aw88261"
            "snd_soc_lpass_rx_macro"
            "snd_soc_lpass_tx_macro"
            "snd_soc_lpass_va_macro"
            "snd_soc_lpass_wsa_macro"
            "snd_soc_sm8250"
            "snd_soc_wcd938x"
            "soundwire_qcom"
            "spi_geni_qcom"
            "ufs_qcom"
            "venus_core"
        ];
        extraFirmwarePaths = [
            "novatek/nt36532_tianma.bin"
            "novatek/nt36532_csot.bin"
            "qcom/sm8250/xiaomi/pipa/venus.mbn"
            "qcom/a650_sqe.fw"
            "qcom/a650_gmu.bin"
            "qcom/sm8250/xiaomi/pipa/a650_zap.mbn"
        ];
    };

    ## TODO: fix hibernation and resume
    boot.resumeDevice = "/dev/disk/by-partlabel/super";
    swapDevices = [{ device = "/dev/disk/by-partlabel/super"; }];

    #          "zswap.enabled=1" "zswap.compressor=zstd" "zswap.max_pool_percent=20" "zswap.shrinker_enabled=1"
    # fix orientation
    boot.kernelParams = [ "video=DSI-1:panel_orientation=right_side_up" ];
    services.udev.extraRules = ''
        SUBSYSTEM=="misc", KERNEL=="fastrpc-*",     ENV{ACCEL_MOUNT_MATRIX}+="0, 1, 0; -1, 0, 0; 0, 0, 1"
        SUBSYSTEM=="misc", KERNEL=="fastrpc-adsp*", ENV{IIO_SENSOR_PROXY_TYPE}+="ssc-accel ssc-proximity"
        SUBSYSTEM=="misc", KERNEL=="fastrpc-sdsp*", ENV{IIO_SENSOR_PROXY_TYPE}+="ssc-accel ssc-proximity"
    '';

    ## prevent switching slot
    systemd.services.qbootctl-mark-successful = {
        description = "Mark a successful boot";
        after = ["graphical.target"];
        wantedBy = ["graphical.target"];
        serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.qbootctl}/bin/qbootctl -m";
        };
    };

    services.fwupd.enable = true;
    hardware.graphics.enable = true;

    ## sensors
    hardware.sensor.iio.enable = true;
    systemd.services.hexagonrpc-sdsp = {
        description = "Hexagonrpcd SDSP Daemon to support Qualcomm Hexagon SDSP virtual filesystem";
        requires = ["dev-fastrpc\\x2dsdsp.device"];
        after = ["dev-fastrpc\\x2dsdsp.device"];
        requiredBy = ["iio-sensor-proxy.service"];
        before = ["iio-sensor-proxy.service"];
        serviceConfig = {
            ExecStart = with pkgs; ''
                ${hexagonrpc}/bin/hexagonrpcd -s -f /dev/fastrpc-sdsp -R ${pipa-firmware}/share/qcom/sm8250/Xiaomi/pipa
            '';
        };
    };

    ## audio
    services.pipewire.enable = false;
    services.pulseaudio.enable = true;
    environment.sessionVariables.ALSA_CONFIG_UCM2 = "${pkgs.pipa-device}/share/alsa/ucm2";

    ## bluetooth
    hardware.bluetooth.enable = true;
    services.udev.packages = with pkgs; [ bootmac ];
    systemd.packages = [ pkgs.bootmac ];

    ## filesystems
    klozher.tmpfs-on-root = {
        enable = true;
        persistDev = {
            device = "/dev/disk/by-partlabel/userdata";
            fsType = "f2fs";
            options = [ "compress_algorithm=zstd:6" "compress_chksum" "atgc" "gc_merge" "lazytime" ];
        };
    };
    fileSystems = {
        "/boot" = {
            device = "PARTLABEL=cust";
            fsType = "vfat";
            options = [ "fmask=0077" "dmask=0077" ];
        };
    };

    #systemd.network = {
    #    enable = false;
    #    # avoid renameing of wlan0 for bootmac to work
    #    links."10-wlan0".enable = true;
    #    links."10-wlan0".matchConfig.OriginalName = "wlan0";
    #    # enable dhcp in usb0
    #    networks."10-usb0".enable = true;
    #    networks."10-usb0".matchConfig.Name = "usb0";
    #    networks."10-usb0".address = [ "172.16.42.1/30" ];
    #    networks."10-usb0".networkConfig.DHCPServer = true;
    #    networks."10-usb0".dhcpServerConfig = {
    #        EmitDNS = false;
    #        EmitNTP = false;
    #        EmitSIP = false;
    #        EmitPOP3 = false;
    #        EmitSMTP = false;
    #        EmitLPR = false;
    #        EmitRouter = false;
    #        EmitTimezone = false;
    #        PersistLeases= false;
    #    };
    #};
    ## dhcp server port
    #networking.firewall.allowedUDPPorts = [67];
    ## disable random mac address
    #networking.networkmanager.wifi.scanRandMacAddress = false;
    #kernelModules = [
    #    #for network interface usb0
    #    "g_ether"
    #];

}

