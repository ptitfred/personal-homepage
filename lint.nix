{ nix-linter
, writeShellApplication
, spago
}:

writeShellApplication {
  name = "lint";
  runtimeInputs = [ nix-linter ];
  text = ''
    set -e
    find . -type f \
      -name "*.nix" \
      ! -path "./scripting/spago-packages.nix" \
      ! -path "./scripting/.spago/*" \
      ! -path "./nix/*" \
      -exec nix-linter {} +
  '';
}
