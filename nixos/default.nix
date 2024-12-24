{ overlays }:

{ ... }:

{
  imports = [ ./website.nix ];

  nixpkgs.overlays = overlays;
}
