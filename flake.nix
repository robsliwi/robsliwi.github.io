{
  description = "robsliwi's blog as a Nix flake";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-unstable;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # to work with older version of flakes
        lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

        # Generate a user-friendly version number.
        version = builtins.substring 0 8 lastModifiedDate;

        # pkgs is easier to write then some lengthy ${system} thing
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        packages = {
          website = pkgs.stdenv.mkDerivation {
            pname = "robsliwi website";
            version = version;
            src = ./.;
            nativeBuildInputs = [ pkgs.hugo ];
            buildPhase = "hugo";
            installPhase = "cp -r public $out";
          };
          default = self.packages.${system}.website;
        };
        devShells.default = with pkgs; mkShell {
          packages = [ hugo ];
        };
      }
    );
}
