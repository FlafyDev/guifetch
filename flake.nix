{
  description = "virtual environments";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; }; 
    in {
      packages = rec {
        guifetch = pkgs.callPackage ./nix/package.nix { };
      };
      devShell =         pkgs.mkShell {
          buildInputs = with pkgs; [
            at-spi2-core.dev
            clang
            cmake
            dart
            dbus.dev
            flutter
            gtk3
            libdatrie
            libepoxy.dev
            libselinux
            libsepol
            libthai
            libxkbcommon
            ninja
            pcre
            pkg-config
            util-linux.dev
            xorg.libXdmcp
            xorg.libXtst
          ];
          shellHook = ''
            export LD_LIBRARY_PATH=${pkgs.libepoxy}/lib
          '';
        };
    });
}

