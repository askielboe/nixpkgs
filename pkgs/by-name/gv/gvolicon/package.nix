{
  lib,
  stdenv,
  makeWrapper,
  alsa-lib,
  pkg-config,
  fetchFromGitHub,
  gtk3,
  adwaita-icon-theme,
  gdk-pixbuf,
  librsvg,
  wrapGAppsHook3,
}:

stdenv.mkDerivation {
  pname = "gvolicon";
  version = "0-unstable-2014-04-28";

  src = fetchFromGitHub {
    owner = "Unia";
    repo = "gvolicon";
    rev = "0d65a396ba11f519d5785c37fec3e9a816217a07";
    sha256 = "sha256-lm5OfryV1/1T1RgsVDdp0Jg5rh8AND8M3ighfrznKes=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];
  buildInputs = [
    alsa-lib
    gtk3
    gdk-pixbuf
    adwaita-icon-theme
    librsvg
    wrapGAppsHook3
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  env.NIX_CFLAGS_COMPILE = "-D_POSIX_C_SOURCE";

  meta = {
    description = "Simple and lightweight volume icon that sits in your system tray";
    homepage = "https://github.com/Unia/gvolicon";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.bennofs ];
    mainProgram = "gvolicon";
  };
}
