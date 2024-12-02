{ writeShellApplication
, python39
, port
, static
}:

writeShellApplication {
  name = "local";
  runtimeInputs = [ python39 ];
  text = ''
    echo "Serving ${static}"
    python3 -m http.server ${port} --directory ${static}
  '';
}
