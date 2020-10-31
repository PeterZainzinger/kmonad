let config = import ./config.nix;
in { pkgs ? import <nixpkgs> { inherit config; } }:
let

  #pkgs   = import (import ./pinned-nixpkgs.nix) { inherit config; };
in pkgs.haskellPackages.shellFor {
  packages = p: [ p.kmonad ];
  withHoogle = true;
  buildInputs =
    [ pkgs.haskellPackages.cabal-install pkgs.haskellPackages.kmonad ];
}
