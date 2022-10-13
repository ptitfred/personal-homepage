{ root
}:

let extraConfig = builtins.readFile ./nginx.conf;

in { inherit root extraConfig; }
