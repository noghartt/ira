{
  description = "A simply typed lambda calculus interpreter flaked";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        haskellPkgs = pkgs.haskell.packages."ghc8107";

        devTools = with haskellPkgs; [
          ghc
          ghcid
          ormolu
          hlint
          hoogle
          haskell-language-server
          implicit-hie
          retrie
          stack-wrapped
        ] ++ [ pkgs.zlib ];

        stack-wrapped = pkgs.symlinkJoin {
          name = "stack";
          paths = [ pkgs.stack ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/stack \
              --add-flags "\
                --no-nix \
                --system-ghc \
                --no-install-ghc \
              "
          '';
        };
      in {
        devShell = pkgs.mkShell {
          buildInputs = devTools;

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath devTools;
        };
      }
    );
}
