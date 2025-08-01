{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  which,
  installShellFiles,
}:

rustPlatform.buildRustPackage rec {
  pname = "dotter";
  version = "0.13.3";

  src = fetchFromGitHub {
    owner = "SuperCuber";
    repo = "dotter";
    rev = "v${version}";
    hash = "sha256-7YExvmuliTL9oagXNUtZ7ZOPyELcS+igK1tXdhG0kQk=";
  };

  cargoHash = "sha256-UBZZu8D1fbNOn2obviP+/Qw+E/OoNKRA4NXzqCqghGs=";

  nativeCheckInputs = [
    which
    installShellFiles
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd dotter \
      --bash <($out/bin/dotter gen-completions --shell bash) \
      --fish <($out/bin/dotter gen-completions --shell fish) \
      --zsh <($out/bin/dotter gen-completions --shell zsh)
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Dotfile manager and templater written in rust 🦀";
    homepage = "https://github.com/SuperCuber/dotter";
    license = licenses.unlicense;
    maintainers = with maintainers; [ linsui ];
    mainProgram = "dotter";
  };
}
