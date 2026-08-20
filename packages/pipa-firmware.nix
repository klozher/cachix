{stdenvNoCC, fetchFromGitHub}:
stdenvNoCC.mkDerivation {
    pname = "pipa-firmware";
    version = "2024-12-29";
    src = fetchFromGitHub {
        owner = "pipa-mainline";
        repo = "xiaomi-pipa-firmware";
        rev = "842d35beffeda8c6d1b0e611b335543bf0e6b41e";
        hash = "sha256-NPApyQVkcDXcxNh1AK863r6VQGP4VQMapoFgHYni8fA=";
    };
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
        mkdir $out
        cp -r usr/share $out/
        cp -r lib $out/
        mkdir "$out/lib/firmware/qcom";
        mv "$out/lib/firmware/sm8250" "$out/lib/firmware/qcom/"
    '';
}

