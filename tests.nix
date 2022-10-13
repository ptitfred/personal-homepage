{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { inherit system; }
, cores ? 1
, memorySize ? 256
}:

with import <nixpkgs/nixos/lib/testing-python.nix> { inherit system pkgs; };

let website = pkgs.callPackage ./nginx.nix { baseUrl = "http://localhost"; };
in
  makeTest {
    nodes.machine = { ... }: {
      virtualisation = {
        inherit cores memorySize;
      };

      services.nginx.enable = true;
      services.nginx.virtualHosts.local = {
        locations."/" = {
          inherit (website) root extraConfig;
        };
      };

      environment.systemPackages = with pkgs; [ httpie ];
    };

    testScript = builtins.readFile ./integration-test.py;
  }
