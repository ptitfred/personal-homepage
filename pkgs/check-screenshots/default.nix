{ writeShellApplication
, curl
, findutils
, htmlq
, httpie
}:

writeShellApplication {
  name = "check-screenshots";
  runtimeInputs = [ curl findutils htmlq httpie ];
  text = builtins.readFile ./script.sh;
}
