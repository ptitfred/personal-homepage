{ httpie
, ptitfred
, cores
, memorySize
, testing-python
}:

let nginx = ptitfred.nginx.override { baseUrl = "http://localhost"; };
in
  testing-python.makeTest {
    name = "personal-homepage-hosting";
    nodes.machine = { ... }: {
      virtualisation = {
        inherit cores memorySize;
      };

      users.users.test_user = {
        isNormalUser = true;
        description = "Test User";
        password = "foobar";
        uid = 1000;
      };

      services.nginx.enable = true;
      services.nginx.virtualHosts.local = {
        locations."/" = {
          inherit (nginx) root extraConfig;
        };
      };

      environment.systemPackages = [ httpie ptitfred.take-screenshots ];
    };

    testScript = builtins.readFile ./integration-test.py;
  }
