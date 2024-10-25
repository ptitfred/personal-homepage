{ writeShellApplication
, curl
, findutils
, htmlq
, imagemagick
, puppeteer-cli
}:

writeShellApplication {
  name = "take-screenshots";
  runtimeInputs = [ curl findutils htmlq imagemagick puppeteer-cli ];
  text = builtins.readFile ./take-screenshots.sh;
}
