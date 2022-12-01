{ pkgs ? import <nixpkgs> { }
, system ? builtins.currentSystem
, nodejs ? pkgs.nodejs-16_x
}:

let
  nodePackages = import ./default.nix {
    inherit pkgs system nodejs;
  };

  opencollective-src = pkgs.fetchFromGitHub {
    owner = "cidkidnix";
    repo = "opencollective-postinstall";
    rev = "c47321886e2e10ba03c806f36dea757dfa53fd1a";
    sha256 = "sha256-o3ogi4CnpRjsCSWSrXsKBLlsKzeGN8PD05SovxIEULQ=";
  };

  opencollective = import "${opencollective-src}/override.nix" { inherit nodejs; };
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
