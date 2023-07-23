{ system ? builtins.currentSystem
}:

(import ./flake-compat.nix).packages.${system}
