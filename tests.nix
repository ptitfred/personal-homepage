{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { inherit system; }
, cores ? 1
, memorySize ? 256
}:

with import <nixpkgs/nixos/lib/testing-python.nix> { inherit system pkgs; };

let website = pkgs.callPackage ./nginx.nix { baseUrl = "http://localhost"; };
in
{
  nginx = makeTest {
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

    testScript = ''
      machine.start();
      machine.wait_for_unit("nginx.service");

      with subtest("Base files present"):
        machine.succeed("http http://localhost/index.html");
        machine.succeed("http http://localhost/sitemap.xml");

      with subtest("Legacy URLs still there (by redirections)"):
        machine.succeed("http http://localhost/about.html");
        machine.succeed("http http://localhost/resume.html");
        machine.succeed("http http://localhost/blog");
        machine.succeed("http http://localhost/tutorials");
    '';
  };
}
