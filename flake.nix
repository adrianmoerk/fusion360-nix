{
  description = "Autodesk Fusion launcher for NixOS using GE-Proton";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    packages.${system} = {
      fusion360 = pkgs.callPackage ./pkgs/fusion360.nix {};
      default = self.packages.${system}.fusion360;
    };
    apps.${system} = {
      default = {
        type = "app";
        meta.description = "Autodesk Fusion launcher";
        program = "${self.packages.${system}.fusion360}/bin/fusion360";
      };
      install = {
        type = "app";
        meta.description = "Autodesk Fusion launcher";
        program = "${self.packages.${system}.fusion360}/bin/fusion360-install";
      };
    };
    checks.${system}.launcher =
      pkgs.runCommand "fusion360-launcher-check" {
        nativeBuildInputs = [pkgs.python3 pkgs.bash];
      } ''
        export HOME="$TMPDIR/home"
        mkdir -p "$HOME"
        python3 ${./tests/launcher.py} ${self.packages.${system}.fusion360}
        touch "$out"
      '';
    homeManagerModules.default = import ./home/fusion360.nix;
    formatter.${system} = pkgs.alejandra;
  };
}
