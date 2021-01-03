{
  description = "mkv-tagify";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.haskell-nix.url = "github:input-output-hk/haskell.nix";

 outputs = { self, nixpkgs, flake-utils, haskell-nix }:
   flake-utils.lib.eachSystem [ "x86_64-darwin" "x86_64-linux" ] (system:
  let
    # use the package set from haskell-nix to avoid rebuilding ghc
    pkgs = nixpkgs.legacyPackages.${system};
    hpkgs = haskell-nix.legacyPackages.${system};
    project = hpkgs.haskell-nix.cabalProject {
        src = hpkgs.haskell-nix.haskellLib.cleanGit {
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
        buildInputs = [ pkgs.haskell-language-server hpkgs.haskellPackages.cabal-bounds ];
        exactDeps   = true;
      };
      checks = {
        build = self.defaultPackage.${system};
        test = self.packages.${system}.mkv-tagify-test;
      };
    });
}
