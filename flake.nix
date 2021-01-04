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
      withHoogle = true;
      tools      = {
      cabal = "3.2.0.0";
      hlint = "3.2.3";
      };
      buildInputs = with pkgs.haskellPackages; [ haskell-language-server cabal-bounds ];
      exactDeps   = true;
    };

    checks = {
      build = self.defaultPackage.${system};
      test = self.packages.${system}.mkv-tagify-test;
    };
  });
}
