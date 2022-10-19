{ stdenv, lib, makeWrapper }:

script: inputs:
  stdenv.mkDerivation rec {
    name = "personal-homepage-scripts-" + script;

    src = ./.;

    buildInputs = inputs ++ [ makeWrapper ] ;

    installPhase =
      let runtimePath = lib.makeBinPath inputs;
       in ''
            mkdir -p $out/bin
            cp $src/${script} $out/bin/${script}
            wrapProgram $out/bin/${script} --prefix PATH : "${runtimePath}"
          '';
  }
