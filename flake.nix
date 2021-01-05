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
        index-state       = "2021-01-04T00:00:00Z";
        materialized      = ./mkv-tagify.materialized;
        plan-sha256       = "1apxn3cs8wfnvhmwq7262ra4pjkz77nnz8vr57ksrf0fh9673kas";
    };
  in
  {
    # Keep this around to quickly build mkv-tagify-project.plan-nix for materialization
    legacyPackages = {
      mkv-tagify-project = project;
    };

    packages = {
      mkv-tagify-lib = project.mkv-tagify.components.library;
      mkv-tagify-test = project.mkv-tagify.checks.test;
    };

    defaultPackage = self.packages.${system}.mkv-tagify-lib;

    devShell = project.shellFor {
      packages   = ps: with ps; [ mkv-tagify ];
      withHoogle = true;
      tools      = {
      cabal = "3.2.0.0";
      hlint = "3.2.3";
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
