{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { inherit system; }
, cores ? 1
, memorySize ? 256
}:

with import <nixpkgs/nixos/lib/testing-python.nix> { inherit system pkgs; };

let nginx = (pkgs.callPackage ./. {}).nginx.override { baseUrl = "http://localhost"; };
in
  makeTest {
    name = "personal-homepage-hosting";
    nodes.machine = { ... }: {
      virtualisation = {
        inherit cores memorySize;
      };

      services.nginx.enable = true;
      services.nginx.virtualHosts.local = {
        locations."/" = {
          inherit (nginx) root extraConfig;
        };
      };

      environment.systemPackages = with pkgs; [ httpie ];
    };

    testScript = builtins.readFile ./integration-test.py;
  }
