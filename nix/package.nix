{ lib, flutter, makeBinaryWrapper, pciutils, cacert }:

flutter.buildFlutterApplication {
  pname = "guifetch";
  version = "0.0.3";

  src = ../.;

  nativeBuildInputs = [ makeBinaryWrapper ];

  depsListFile = ./deps.json;
  vendorHash = "sha256-HxlAmAlDHL+Tx7T96RbVSJBNOGetI0l4GmmGFY5W4EE=";

  pubGetScript = "dart --root-certs-file=${cacert}/etc/ssl/certs/ca-bundle.crt pub get";

  meta = with lib; {
    description = "A GUI fetch tool written in Flutter.";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
