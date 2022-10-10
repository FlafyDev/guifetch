{ lib, flutter, makeWrapper, pciutils }:

flutter.mkFlutterApp {
  pname = "guifetch";
  version = "0.0.2";

  src = lib.cleanSourceWith {
    src = ../.;
    filter = (name: type: 
      !(type == "directory" && baseNameOf name == "nix")
    );
  };

  vendorHash = "sha256-aZLnH739uwKuyJGtgarZTSIERrPzgxDS9CondZ3qN0I=";

  nativeBuildInputs = [ makeWrapper ];

  postFixup = ''
    wrapProgram $out/bin/guifetch --suffix PATH : ${lib.makeBinPath [ pciutils ]}
  '';

  meta = with lib; {
    description = "A GUI fetch tool written in Flutter.";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
