{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.fusion360;
  launcher = pkgs.callPackage ../pkgs/fusion360.nix {
    inherit (cfg) stateDirectory wineDesktop desktopSize;
  };
in {
  options.programs.fusion360 = {
    enable = lib.mkEnableOption "Autodesk Fusion through Proton";
    stateDirectory = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.dataHome}/fusion360";
      description = "Private writable directory containing compat/, logs/ and the authentication profile.";
    };
    wineDesktop = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Keep Wine panels together to reduce rendering and input bugs on Niri.";
    };
    desktopSize = lib.mkOption {
      type = lib.types.strMatching "[0-9]+x[0-9]+";
      default = "1600x1000";
      description = "Initial Wine desktop size; the compositor can resize it.";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [launcher];
    xdg.desktopEntries.fusion360-nixos = {
      name = "Autodesk Fusion";
      comment = "CAD using a dedicated Proton prefix";
      exec = "${launcher}/bin/fusion360 %F";
      icon = "applications-engineering";
      terminal = false;
      categories = ["Graphics" "Engineering"];
      settings.StartupWMClass = "explorer.exe";
    };
    xdg.desktopEntries.fusion360-nixos-callback = {
      name = "Autodesk Fusion Sign In";
      exec = "${launcher}/bin/fusion360-callback %u";
      noDisplay = true;
      terminal = false;
      mimeType = ["x-scheme-handler/adsk" "x-scheme-handler/adskidmgr" "x-scheme-handler/adsk.idmgr"];
    };
    # Replace the original per-user launchers too: they take precedence over
    # desktop entries supplied through the profile's share/applications.
    xdg.dataFile."applications/fusion360-nixos.desktop".source = "${config.home.path}/share/applications/fusion360-nixos.desktop";
    xdg.dataFile."applications/fusion360-nixos-callback.desktop".source = "${config.home.path}/share/applications/fusion360-nixos-callback.desktop";
    xdg.mimeApps.enable = true;
    xdg.mimeApps.defaultApplications =
      lib.genAttrs
      ["x-scheme-handler/adsk" "x-scheme-handler/adskidmgr" "x-scheme-handler/adsk.idmgr"]
      (_: ["fusion360-nixos-callback.desktop"]);
  };
}
