{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    diagonal-b6.url = "github:diagonalworks/diagonal-b6/v0.2.3";
    diagonal-b6.inputs.nixpkgs.follows = "nixpkgs";
  };


  outputs =
    { self
    , nixpkgs
    , flake-utils
    , diagonal-b6
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      py-env = pkgs.python312.withPackages (ps: with ps; [
        diagonal-b6.packages."${system}".python312
        geopandas
        jupyter
        more-itertools
        pandas
        tqdm
      ]);
    in
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          py-env
          diagonal-b6.packages.${system}.run-b6
          diagonal-b6.packages.${system}.go
          osmium-tool
        ];
      };
    });


  # Cachix setup: Use the diagonalworks cachix by default, to save extra
  # building!
  nixConfig = {
    extra-substituters = [
      "https://diagonalworks.cachix.org"
    ];
    extra-trusted-public-keys = [
      "diagonalworks.cachix.org-1:7U834B3foDCfa1EeV6xpyOz9JhdfUXj2yxRv0rAdYMk="
    ];
  };
}
