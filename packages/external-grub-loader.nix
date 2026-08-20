{writeShellApplication, util-linux, coreutils}:
writeShellApplication {
    name = "external-grub-loader";
    runtimeInputs = [ util-linux coreutils ];
    text = builtins.readFile ./external-grub-loader.sh;
}

