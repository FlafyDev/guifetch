{
  description = "GUI fetch tool written in Flutter for Linux.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=2277e4c9010b0f27585eb0bed0a86d7cbc079354";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; }; 
    in {
      packages = rec {
        guifetch = pkgs.callPackage ./nix/package.nix { };
        default = guifetch;
      };
      devShell = pkgs.mkShell {
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
    }) // {
      overlays.default = final: prev: let 
        pkgs = import nixpkgs { 
          inherit (prev) system;
        };
      in {
        guifetch = pkgs.callPackage ./nix/package.nix { };
      };
    };
}

