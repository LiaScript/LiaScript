# Nix Shell for LiaScript
{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  name = "liascript-env";

  buildInputs = with pkgs; [
    elmPackages.elm
    elmPackages.elm-format
    elmPackages.elm-test
    elmPackages.elm-analyse
    nodejs-14_x
  ];

  shellHook = ''
    export PATH=$PATH:$(npm bin)
  '';
}
