{
  description = "mkv-tagify";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.haskell-nix.url = "github:input-output-hk/haskell.nix";

  outputs = { self, nixpkgs, flake-utils, haskell-nix }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    # use the package set from haskell-nix to avoid rebuilding ghc
    pkgs = nixpkgs.legacyPackages.${system};
    hpkgs = haskell-nix.legacyPackages.${system};
  in
  {
      packages.project = hpkgs.haskell-nix.cabalProject {
        src = hpkgs.haskell-nix.haskellLib.cleanGit {
          src = ./.;
          name = "mkv-tagify";
        };
        compiler-nix-name = "ghc884";
      };
      packages.shell = self.packages.${system}.project.shellFor {
        packages   = ps: with ps; [ mkv-tagify ];
        withHoogle = true;
        tools      = {
          cabal = "3.2.0.0";
          hlint = "3.2.3";
        };
        buildInputs = with pkgs; [ haskell-language-server ];
        exactDeps   = true;
      };
      defaultPackage = self.packages.${system}.project.mkv-tagify.components.exes.mkv-tagify;
      defaultApp = {
        type = "app";
        program = "${self.defaultPackage.${system}}/bin/mkv-tagify";
      };
      devShell = self.packages.${system}.shell;
      overlay = import ./overlay.nix;
    });
}