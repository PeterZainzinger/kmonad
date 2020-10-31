{
  inputs = { flake-utils.url = "github:numtide/flake-utils"; };
  outputs = { self, nixpkgs, flake-utils }:
    ({
      nixosModule = { config, pkgs, lib, ... }:
        with lib;
        let cfg = config.services.kmonad;
        in {
          options.services.kmonad = {
            enable = mkEnableOption "kmonad";
            config = mkOption { type = types.lines; };
          };
          config = mkIf cfg.enable {
            environment.systemPackages = with pkgs;
              [ self.defaultPackage.aarch64-linux ];
            systemd.services."kmonad" = {
              enable = true;
              path = [ self.defaultPackage.aarch64-linux pkgs.bash ];
              serviceConfig = { ExecStart = "kmonad /etc/kmonad_config.kbd"; };
              wants = [ "systemd-udev-settle.service" ];
              after = [ "systemd-udev-settle.service" ];
              wantedBy = [ "multi-user.target" ];
            };
            environment.etc."kmonad_config.kbd" = {
              mode = "004";
              text = cfg.config;
            };
          };
        };

    } // flake-utils.lib.eachDefaultSystem (system:

      let
        config = import ./nix/config.nix;
        pkgs = import nixpkgs {
          system = system;
          inherit config;
        };
      in {
        defaultPackage = (import ./nix/kmonad.nix) {
          mkDerivation = pkgs.stdenv.mkDerivation;
          base = pkgs.haskellPackages.base;
          cereal = pkgs.haskellPackages.cereal;
          lens = pkgs.haskellPackages.lens;
          megaparsec = pkgs.haskellPackages.megaparsec;
          mtl = pkgs.haskellPackages.mtl;
          optparse-applicative = pkgs.haskellPackages.optparse-applicative;
          resourcet = pkgs.haskellPackages.resourcet;
          rio = pkgs.haskellPackages.rio;
          stdenv = pkgs.stdenv;
          time = pkgs.haskellPackages.time;
          unix = pkgs.haskellPackages.unix;
          unliftio = pkgs.haskellPackages.unliftio;
        };
        devShell = import ./nix/shell.nix { inherit pkgs; };

      }));
}
