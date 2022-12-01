{ pkgs ? import <nixpkgs> { }
, system ? builtins.currentSystem
, nodejs ? pkgs.nodejs-16_x
}:

let
  nodePackages = import ./default.nix {
    inherit pkgs system nodejs;
  };

  opencollective = import ../opencollective-postinstall/override.nix { inherit nodejs; };
in
nodePackages // {
  nodeDependencies = nodePackages.nodeDependencies.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [
      pkgs.nodePackages.node-gyp-build
      opencollective.package
    ];
  });

  package = nodePackages.package.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [
      pkgs.nodePackages.node-gyp-build
      opencollective.package
    ];

    installPhase = builtins.replaceStrings [ "chmod u+rwx" ] [ "[ ! -d $file ] && mkdir -p $file || chmod u+rwx " ] old.installPhase;
  });
}
