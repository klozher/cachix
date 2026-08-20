{lib, stdenv, fetchFromGitLab, meson, ninja, makeWrapper, coreutils, gnugrep, util-linux, gnused, bluez, gawk, iproute2}:
stdenv.mkDerivation rec {
    pname = "bootmac";
    version = "0.7.1";
    src = fetchFromGitLab {
      domain = "gitlab.postmarketos.org";
      owner = "postmarketOS";
      repo = "bootmac";
      rev = "v${version}";
      hash = "sha256-GWvZUC8LKPpOWt1oCr93JHg5+W+0CCiYT63VhpSH1ko=";
    };
    nativeBuildInputs = [ meson ninja makeWrapper ];
    mesonFlags = [ "-Dsystemd_units=true" ];
    postInstall = ''
      substituteInPlace $out/lib/systemd/system/bootmac@.service \
        --replace-fail "/usr/bin" "$out/bin"
      substituteInPlace $out/lib/udev/rules.d/90-bootmac-bluetooth.rules \
        --replace-fail "/usr/bin" "$out/bin"
      substituteInPlace $out/lib/udev/rules.d/90-bootmac-wifi.rules \
        --replace-fail "/usr/bin" "$out/bin"
      wrapProgram $out/bin/bootmac --prefix PATH : ${lib.makeBinPath [ coreutils gnugrep util-linux gnused bluez gawk iproute2 ]}
    '';
}

