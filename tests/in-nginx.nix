{ httpie
, cores
, memorySize
, testers
, nixosModule
, ptitfred
}:

testers.nixosTest {
  name = "personal-homepage-hosting";
  nodes.machine = { ... }: {
    imports = [ nixosModule ];

    virtualisation = {
      inherit cores memorySize;
    };

    services.ptitfred.personal-homepage = {
      enable = true;
      domain = "long.test.localhost";
      aliases = [ "test.localhost" ];
      redirections = [
        { path = "/example";  target = "http://long.test.localhost/open-source"; }
        { path = "/example/"; target = "http://long.test.localhost/open-source"; }
      ];

      # Explicitly disable HTTPs as we can't have the ACME dance in the VM
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

    # disable the timers in the VM
    systemd.timers.homepage-deployment.enable = false;
  };

  testScript = builtins.readFile ./integration-test.py;
}
