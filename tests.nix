{ pkgs
, cores
, memorySize
, testing-python
}:

let nginx = pkgs.ptitfred.nginx.override { baseUrl = "http://localhost"; };
in
  testing-python.makeTest {
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
