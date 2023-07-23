{ writeShellApplication
, python38
, port
, static
}:

writeShellApplication {
  name = "local";
  runtimeInputs = [ python38 ];
  text = ''
    echo "Serving ${static}"
    python3 -m http.server ${port} --directory ${static}
  '';
}
