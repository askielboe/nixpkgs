{
  lib,
  stdenv,
  runtimeShell,
  pkg-config,
  gettext,
  ncurses,
  tiles,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  SDL2_ttf,
  libX11,
  freetype,
  zlib,
  debug,
  useXdgDir,
}:

let
  inherit (lib) optionals optionalString;

  commonDeps = [
    gettext
    zlib
  ];

  cursesDeps = commonDeps ++ [ ncurses ];

  tilesDeps = commonDeps ++ [
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    libX11
    freetype
  ];

  patchDesktopFile = ''
    substituteInPlace $out/share/applications/org.cataclysmdda.CataclysmDDA.desktop \
      --replace-fail "Exec=cataclysm-tiles" "Exec=$out/bin/cataclysm-tiles"
  '';

  installMacOSAppLauncher = ''
    app=$out/Applications/Cataclysm.app
    install -D -m 444 build-data/osx/Info.plist -t $app/Contents
    install -D -m 444 build-data/osx/AppIcon.icns -t $app/Contents/Resources
    mkdir $app/Contents/MacOS
    launcher=$app/Contents/MacOS/Cataclysm.sh
    cat << EOF > $launcher
    #!${runtimeShell}
    $out/bin/cataclysm-tiles
    EOF
    chmod 555 $launcher
  '';
in

stdenv.mkDerivation {
  pname = "cataclysm-dda";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = if tiles then tilesDeps else cursesDeps;

  postPatch = ''
    patchShebangs lang/compile_mo.sh
  '';

  makeFlags = [
    "PREFIX=$(out)"
    "LANGUAGES=all"
    (if useXdgDir then "USE_XDG_DIR=1" else "USE_HOME_DIR=1")
  ]
  ++ optionals (!debug) [
    "RELEASE=1"
  ]
  ++ optionals tiles [
    "TILES=1"
    "SOUND=1"
  ]
  ++ optionals stdenv.hostPlatform.isDarwin [
    "NATIVE=osx"
    "CLANG=1"
    "OSX_MIN=${stdenv.hostPlatform.darwinMinVersion}"
  ];

  postInstall = optionalString tiles (
    if !stdenv.hostPlatform.isDarwin then patchDesktopFile else installMacOSAppLauncher
  );

  dontStrip = debug;
  enableParallelBuilding = true;

  passthru = {
    isTiles = tiles;
    isCurses = !tiles;
  };

  meta = with lib; {
    description = "Free, post apocalyptic, zombie infested rogue-like";
    mainProgram = "cataclysm-tiles";
    longDescription = ''
      Cataclysm: Dark Days Ahead is a roguelike set in a post-apocalyptic world.
      Surviving is difficult: you have been thrown, ill-equipped, into a
      landscape now riddled with monstrosities of which flesh eating zombies are
      neither the strangest nor the deadliest.

      Yet with care and a little luck, many things are possible. You may try to
      eke out an existence in the forests silently executing threats and
      providing sustenance with your longbow. You can ride into town in a
      jerry-rigged vehicle, all guns blazing, to settle matters in a fug of
      smoke from your molotovs. You could take a more measured approach and
      construct an impregnable fortress, surrounded by traps to protect you from
      the horrors without. The longer you survive, the more skilled and adapted
      you will get and the better equipped and armed to deal with the threats
      you are presented with.

      In the course of your ordeal there will be opportunities and temptations
      to improve or change your very nature. There are tales of survivors fitted
      with extraordinary cybernetics giving great power and stories too of
      gravely mutated survivors who, warped by their ingestion of exotic
      substances or radiation, now more closely resemble insects, birds or fish
      than their original form.
    '';
    homepage = "https://cataclysmdda.org/";
    license = licenses.cc-by-sa-30;
    maintainers = with maintainers; [
      mnacamura
      DeeUnderscore
    ];
    platforms = platforms.unix;
  };
}
