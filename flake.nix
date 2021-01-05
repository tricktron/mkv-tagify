{
  description = "mkv-tagify";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.haskell-nix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.url     = "github:NixOS/nixpkgs/f02bf8ffb9a5ec5e8f6f66f1e5544fd2aa1a0693";

 outputs = { self, nixpkgs, flake-utils, haskell-nix }:
   flake-utils.lib.eachSystem [ "x86_64-darwin" "x86_64-linux" ] (system:
  let
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ haskell-nix.overlay ];
    };
    project = pkgs.haskell-nix.cabalProject {
        src = pkgs.haskell-nix.haskellLib.cleanGit {
          src = ./.;
          name = "mkv-tagify";
        };
        compiler-nix-name = "ghc884";
    };
  in
  {
    packages = {
      mkv-tagify-lib = project.mkv-tagify.components.library;
      mkv-tagify-test = project.mkv-tagify.checks.test;
    };

    defaultPackage = self.packages.${system}.mkv-tagify-lib;

    devShell = project.shellFor {
      packages   = ps: with ps; [ mkv-tagify ];
      tools      = {
        cabal = {
          version = "3.2.0.0";
          index-state = "2021-01-04T00:00:00Z";
          plan-sha256 = "0lmg2720nm58zxqzxs0ssfljvny2parx92y1qvz9bsff4q310idi";
          materialized = ./cabal.materialized;
        };
        hlint = {
          version = "3.2.3";
          index-state = "2021-01-04T00:00:00Z";
          plan-sha256 = "1f2pr5y6mwjjdvnsli05xfv41sg31wrx04npvdcyyqqb77wxjpsf";
          materialized = ./hlint.materialized;
        };
      };
      buildInputs = with pkgs.haskellPackages; [ haskell-language-server cabal-bounds ];
      exactDeps   = true;
    };

    apps.repl = flake-utils.lib.mkApp {
        drv = pkgs.writeShellScriptBin "repl" ''
          confnix=$(mktemp)
          echo "builtins.getFlake (toString $(git rev-parse --show-toplevel))" >$confnix
          trap "rm $confnix" EXIT
          nix repl $confnix
        '';
    };

    checks = {
      build = self.defaultPackage.${system};
      test = self.packages.${system}.mkv-tagify-test;
    };
  });
}
