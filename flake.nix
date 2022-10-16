{
  description = "GUI fetch tool written in Flutter for Linux.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    dart-flutter.url = "github:flafydev/dart-flutter-nix";
  };

  outputs = { self, flake-utils, nixpkgs, dart-flutter }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ dart-flutter.overlays.default ];
      }; 
    in {
      packages = rec {
        guifetch = pkgs.callPackage ./nix/package.nix { };
        default = guifetch;
      };
      devShell = pkgs.mkShell {
        packages = [
          pkgs.deps2nix
        ];
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

