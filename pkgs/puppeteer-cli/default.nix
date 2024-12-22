{
  lib,
  buildNpmPackage,
  makeWrapper,
  chromium,
}:

buildNpmPackage {
  pname = "puppeteer-cli";
  version = "1.6.0";

  src = ./src;

  npmDepsHash = "sha256-Xb9gUzJykYJUP3OEDq/EMoFNPsq/1u0TcOZWSOoxeus=";

  env = {
    PUPPETEER_SKIP_DOWNLOAD = true;
  };

  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/puppeteer \
      --set PUPPETEER_EXECUTABLE_PATH ${chromium}/bin/chromium
  '';

  meta = {
    description = "Command-line wrapper for generating PDF prints and PNG screenshots with Puppeteer";
    homepage = "https://github.com/JarvusInnovations/puppeteer-cli";
    license = lib.licenses.mit;
    mainProgram = "puppeteer";
    maintainers = with lib.maintainers; [ chessai ];
  };
}
