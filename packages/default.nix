# Collects the packages in this directory.
#
# Single-package files: one derivation per file, named after the file.
# Each file is callPackage'd with exactly the dependencies it declares in
# its argument header; missing arguments resolve from nixpkgs, from the
# other single-package files here, and from bundle files below — so
# packages may depend on each other freely.
#
# Bundle files (listed in `bundles`) return an attrset of packages
# instead of a single derivation. They are self-contained — internal
# dependencies must be resolved within the file (rec / its own
# callPackage), as pipa.nix does — and their packages are merged into
# the top level, keeping their current names.
{ pkgs }:
let
    inherit (pkgs) lib;

    files = lib.filterAttrs
        (name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix")
        (builtins.readDir ./.);

    scope = lib.makeScope pkgs.newScope (self:
        lib.mapAttrs'
            (name: _:
                lib.nameValuePair
                    (lib.removeSuffix ".nix" name)
                    (self.callPackage ./${name} { }))
            files);
in builtins.removeAttrs scope [ "callPackage" "newScope" "overrideScope" "packages" ]

