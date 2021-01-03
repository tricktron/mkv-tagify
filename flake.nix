{
  description = "mkv-tagify";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.haskell-nix.url = "github:input-output-hk/haskell.nix";

 outputs = { self, nixpkgs, flake-utils, haskell-nix }:
  let
    system = "x86_64-darwin";
    # use the package set from haskell-nix to avoid rebuilding ghc
    pkgs = nixpkgs.legacyPackages.${system};
    hpkgs = haskell-nix.legacyPackages.${system};
  in
  {
      project = hpkgs.haskell-nix.cabalProject {
        src = hpkgs.haskell-nix.haskellLib.cleanGit {
          src = ./.;
          name = "mkv-tagify";
        };
        compiler-nix-name = "ghc884";
      };
      defaultPackage.${system} = self.project.mkv-tagify.components.tests.test;
      defaultApp.${system} = {
        type = "app";
        program = "${self.defaultPackage.${system}}/bin/mkv-tagify";
      };
      devShell.${system} = self.project.shellFor {
        packages   = ps: with ps; [ mkv-tagify ];
        withHoogle = true;
        tools      = {
          cabal = "3.2.0.0";
          hlint = "3.2.3";
        };
        buildInputs = [ pkgs.haskell-language-server hpkgs.haskellPackages.cabal-bounds ];
        exactDeps   = true;
      };
      overlay = import ./overlay.nix;
      checks.${system} = {
        build = self.defaultPackage.${system};
        test = self.project.mkv-tagify.checks.test;
      };
    };
}
