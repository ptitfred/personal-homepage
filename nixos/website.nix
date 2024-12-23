{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ptitfred.personal-homepage;

  enabled = cfg.enable && config.services.nginx.enable;

  brotlify = pkgs.callPackage ./brotlify.nix { };

  nginx = pkgs.ptitfred.website.nginx.override { inherit baseUrl; };

  baseUrl = if cfg.secure then "https://${cfg.domain}" else "http://${cfg.domain}";

  assetsDirectory = "homepage-extra-assets";
  screenshotsSubdirectory = "og";

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

  mkRedirection = { path, target }: "rewrite ^${path}$ ${target} permanent;";

  extraConfig = ''
    ${nginx.extraConfig}
    ${lib.strings.concatMapStringsSep "\n" mkRedirection cfg.redirections}
  '';

  hostingHost =
    {
      ${cfg.domain} = {
        forceSSL = cfg.secure;
        enableACME = lib.mkIf cfg.secure true;

        locations."/" = {
          root = brotlify { src = nginx.root; };
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

        after    = [ "nginx.service" ];
        requires = [ "nginx.service" ];
        partOf = [ "default.target" ];

        script = ''
          mkdir -p /var/lib/${assetsDirectory}/${screenshotsSubdirectory}
          ${pkgs.ptitfred.take-screenshots}/bin/take-screenshots ${baseUrl} /var/lib/${assetsDirectory}/${screenshotsSubdirectory}
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

      security.acme.certs.${cfg.domain} = lib.mkIf cfg.secure {
        extraDomainNames = lib.mkIf cfg.secure cfg.aliases;
      };
    };
  }
