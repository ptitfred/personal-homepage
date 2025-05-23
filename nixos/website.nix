{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ptitfred.personal-homepage;

  enabled = cfg.enable && config.services.nginx.enable;

  websitesDirectory = "www";
  linkPath = "/var/lib/${websitesDirectory}/personal-homepage";

  nginx =
    pkgs.ptitfred.website.nginx.override {
      inherit baseUrl;
    };

  deploy-from-flake =
    pkgs.ptitfred.deploy-from-flake.deployment.override {
      inherit baseUrl linkPath screenshotsDirectory;
      inherit (cfg) flakeInput;
    };

  activation-script =
    pkgs.ptitfred.deploy-from-flake.activation-script.override {
      inherit (nginx) root;
      inherit linkPath;
    };

  baseUrl = if cfg.secure then "https://${cfg.domain}" else "http://${cfg.domain}";

  assetsDirectory = "homepage-extra-assets";
  screenshotsSubdirectory = "og";
  screenshotsDirectory = "/var/lib/${assetsDirectory}/${screenshotsSubdirectory}";

  mkRedirect = alias: vhosts: vhosts // redirect alias;

  vhostRedirectionBaseDefinition = {
    forceSSL = cfg.secure;
    enableACME = cfg.secure;
    globalRedirect = cfg.domain;
  };

  vhostRedirectionOptionalDefinition =
    if cfg.secure
    then { acmeFallbackHost = cfg.domain; }
    else {};

  redirect = alias: {
    "${alias}" = vhostRedirectionBaseDefinition // vhostRedirectionOptionalDefinition;
  };

  mkRedirections = lib.strings.concatMapStringsSep "\n" mkRedirection;

  mkRedirection = { path, target }: "rewrite ^${path}$ ${target} permanent;";

  extraConfig = ''
    ${nginx.extraConfig}
    ${mkRedirections cfg.redirections}
  '';

  hostingHost =
    {
      ${cfg.domain} = {
        forceSSL = cfg.secure;
        enableACME = lib.mkIf cfg.secure true;

        locations."/" = {
          root = linkPath;
          inherit extraConfig;
        };

        locations."/${screenshotsSubdirectory}/" = {
          root = "/var/lib/${assetsDirectory}";
        };
      };
    };

  virtualHosts = foldr mkRedirect hostingHost cfg.aliases;

  redirection = types.submodule {
    options = {
      path = mkOption {
        type = types.str;
        default = false;
      };
      target = mkOption {
        type = types.str;
        default = false;
      };
    };
  };
in
  {
    imports = [
      ./brotli.nix
    ];

    options.services.ptitfred.personal-homepage = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          If enabled, hosts my personal-homepage on this machine (assuming nginx is enabled and listens to the propert ports).
        '';
      };

      secure = mkOption {
        type = types.bool;
        default = true;
        description = ''
          If enabled, sets up HTTPs and enforces it. Defaults to true.
        '';
      };

      domain = mkOption {
        type = types.str;
        description = ''
          CNAME to respond to to host the website.
        '';
      };

      aliases = mkOption {
        type = types.listOf types.str;
        description = ''
          CNAMEs to respond to by redirecting to the domain set at `services.ptitfred.personal-homepage.domain`.
        '';
        default = [];
      };

      redirections = mkOption {
        type = types.listOf redirection;
        description = ''
          Extra URL redirections to inject and that you might not want to have publicly committed.
        '';
        default = [];
      };

      screenshots = mkEnableOption "screenshots" // {
        description = ''
          Option to enable automatic screenshoting (at 2 in the morning local time).
        '';
        default = true;
      };

      flakeInput = mkOption {
        type = types.str;
        default = "github:ptitfred/personal-homepage";
        description = ''
          Flake from which to regularly deploy. Default value should be fine. Configure it if you want to hack around.
        '';
      };
    };

    config = mkIf enabled {
      services.nginx = {
        inherit virtualHosts;
        recommendedGzipSettings = true;
        recommendedProxySettings = true;
        brotliSupport = true;
      };

      systemd.services.homepage-screenshots = {
        description = "Utility to take screenshots.";

        after    = [ "nginx.service"  ];
        requires = [ "nginx.service"  ];
        partOf   = [ "default.target" ];

        script = ''
          ${pkgs.ptitfred.take-screenshots}/bin/take-screenshots ${baseUrl} "${screenshotsDirectory}"
        '';

        serviceConfig = {
          StateDirectory = assetsDirectory;
          StateDirectoryMode = "0750";
          User = "nginx";
          Group = "nginx";
          Type = "oneshot";
        };

        environment = {
          XDG_CONFIG_HOME = "/tmp/.chromium";
          XDG_CACHE_HOME = "/tmp/.chromium";
        };
      };

      systemd.timers.homepage-screenshots = mkIf cfg.screenshots {
        description = "Utility to take screenshots.";
        timerConfig.OnCalendar = "02:00:00";
        wantedBy = [ "timers.target" ];
      };

      systemd.services.homepage-deployment = {
        description = "Utility to install the web pages to a Nix profile";

        after    = [ "nginx.service"  ];
        requires = [ "nginx.service"  ];
        partOf   = [ "default.target" ];

        script = "${deploy-from-flake}/bin/deploy-from-flake";

        serviceConfig = {
          StateDirectory = websitesDirectory;
          StateDirectoryMode = "0750";
          User = "nginx";
          Group = "nginx";
          Type = "oneshot";
        };
      };

      systemd.timers.homepage-deployment = {
        description = "Utility to install the web pages to a Nix profile";
        timerConfig.OnCalendar = "*:*:00";
        wantedBy = [ "timers.target" ];
      };

      security.acme.certs.${cfg.domain} = lib.mkIf cfg.secure {
        extraDomainNames = lib.mkIf cfg.secure cfg.aliases;
      };

      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
      };

      system.activationScripts =
        {
          homepage-deployment = ''
            ${activation-script}/bin/deploy-from-flake-activation-script
          '';
        };
    };
  }
