{
  lib,
  stdenvNoCC,
  fetchurl,
  steam,
  makeWrapper,
  bash,
  coreutils,
  findutils,
  util-linux,
  python3,
  curl,
  firefox,
  xdg-utils,
  gnugrep,
  stateDirectory ? null,
  wineDesktop ? true,
  desktopSize ? "1600x1000",
}: let
  proton = stdenvNoCC.mkDerivation {
    pname = "fusion-proton-ge";
    version = "11-5";
    src = fetchurl {
      url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton11-5/GE-Proton11-5-x86_64.tar.gz";
      hash = "sha512-j7HzrmWo3CLv2Amf9IkHXw7r3fAcRFtCMkRYn28KHhnAHeXR5yK5f8Hrr2OQyBMFLtVSkAWPjSHxNTo2FG9KLA==";
    };
    dontFixup = true;
    installPhase = ''mkdir -p $out; cp -r . $out/'';
  };
  runtime =
    (steam.override {
      extraLibraries = runtimePkgs: [runtimePkgs.freetype runtimePkgs.fontconfig];
      extraBwrapArgs = [
        ''--bind "$FUSION_HOME" "$FUSION_HOME"''
        ''--bind "$FUSION_RUNTIME_SOCKET_DIR" "/tmp/.wine-$(id -u)"''
      ];
    }).run;
in
  stdenvNoCC.mkDerivation {
    pname = "fusion360-launcher";
    version = "1";
    src = ./fusion360;
    nativeBuildInputs = [makeWrapper];
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/libexec/fusion360 $out/bin
      cp *.sh *.py $out/libexec/fusion360/
      chmod +x $out/libexec/fusion360/*.sh
      for pair in fusion360:launch-fusion.sh fusion360-install:install.sh fusion360-callback:fusion-callback.sh; do
        name="''${pair%%:*}"
        script="''${pair#*:}"
        makeWrapper ${bash}/bin/bash "$out/bin/$name" \
          --add-flags "$out/libexec/fusion360/$script" \
          --set FUSION_LIBEXEC "$out/libexec/fusion360" \
          --set-default FUSION_PROTON "${proton}/proton" \
          --set FUSION_RUNTIME "${runtime}" \
          --set FUSION_FIREFOX "${firefox}/bin/firefox" \
          ${lib.optionalString (stateDirectory != null) "--set-default FUSION_HOME ${lib.escapeShellArg stateDirectory}"} \
          --set-default FUSION_WINE_DESKTOP ${
        if wineDesktop
        then "1"
        else "0"
      } \
          --set-default FUSION_DESKTOP_SIZE ${lib.escapeShellArg desktopSize} \
          --prefix PATH : ${lib.makeBinPath [bash coreutils findutils util-linux python3 curl xdg-utils gnugrep]}
      done
    '';
    meta = {
      description = "Autodesk Fusion launcher with a dedicated Proton prefix";
      platforms = ["x86_64-linux"];
      mainProgram = "fusion360";
      license = lib.licenses.mit;
    };
  }
