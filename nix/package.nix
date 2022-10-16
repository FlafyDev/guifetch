{ lib, buildFlutterApp, makeBinaryWrapper, pciutils }:

buildFlutterApp {
  pname = "guifetch";
  version = "0.0.3";

  src = ../.;

  nativeBuildInputs = [ makeBinaryWrapper ];

  postFixup = ''
    wrapProgram $out/bin/guifetch --suffix PATH : ${lib.makeBinPath [ pciutils ]}
  '';

  meta = with lib; {
    description = "A GUI fetch tool written in Flutter.";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
