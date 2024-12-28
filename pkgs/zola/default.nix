{ writeShellScript, zola }:

{
  check      = writeShellScript "zola-check"      "${zola}/bin/zola --root $1 check";
  dev-server = writeShellScript "zola-dev-server" "${zola}/bin/zola --root $1 serve --open";
}
