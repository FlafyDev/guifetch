{ lib, flutter, makeWrapper, pciutils }:

flutter.mkFlutterApp {
  pname = "guifetch";
  version = "0.0.3";

  src = lib.cleanSourceWith {
    src = ../.;
    filter = (name: type: 
      !(baseNameOf name == "nix" || baseNameOf name == "README.md"));
  };

  vendorHash = "sha256-fvJEh6Q+Re5Eq9vjLkW3qpOTtZgtsp9j34TwM4PdAj0=";

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
