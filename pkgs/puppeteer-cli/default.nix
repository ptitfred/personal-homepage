{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  chromium,
}:

buildNpmPackage {
  pname = "puppeteer-cli";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "JarvusInnovations";
    repo = "puppeteer-cli";
    rev = "8671ba41b713e7fa7d49e3718e6d1df06402545c";
    sha256 = "sha256-cZVcWpBnW2GKpravXhR/HlJYjEgRkAAKe3Kz4hszKJ8=";
  };

  npmDepsHash = "sha256-Xb9gUzJykYJUP3OEDq/EMoFNPsq/1u0TcOZWSOoxeus=";

  patches = [ ./disable-gpu.patch ];

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
