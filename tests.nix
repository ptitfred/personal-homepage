{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { inherit system; }
}:

with import <nixpkgs/nixos/lib/testing-python.nix> { inherit system pkgs; };

let website = pkgs.callPackage ./nginx.nix { baseUrl = "http://localhost"; };
in
{
  nginx = makeTest {
    nodes.machine = { ... }: {
      virtualisation.cores = 1;
      virtualisation.memorySize = 256;

      services.nginx.enable = true;
      services.nginx.virtualHosts.local = {
        locations."/" = {
          inherit (website) root extraConfig;
        };
      };

      environment.systemPackages = with pkgs; [ httpie ];
    };

    testScript = ''
      machine.start();
      machine.wait_for_unit("nginx.service");
      machine.succeed("http http://localhost/sitemap.xml");
    '';
  };
}
