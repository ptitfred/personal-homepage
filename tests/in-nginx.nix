{ httpie
, cores
, memorySize
, nixosTest
, nixosModule
, ptitfred
}:

nixosTest {
  name = "personal-homepage-hosting";
  nodes.machine = { ... }: {
    imports = [ nixosModule ];

    virtualisation = {
      inherit cores memorySize;
    };

    services.ptitfred.personal-homepage = {
      enable = true;
      domain = "localhost";
      secure = false;
    };

    users.users.test_user = {
      isNormalUser = true;
      description = "Test User";
      password = "foobar";
      uid = 1000;
    };

    services.nginx.enable = true;

    environment.systemPackages = [ httpie ptitfred.check-screenshots ];
  };

  testScript = builtins.readFile ./integration-test.py;
}
