{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  bzip2,
  zstd,
  stdenv,
  rocksdb,
  nix-update-script,
  testers,
  conduwuit,
  # upstream conduwuit enables jemalloc by default, so we follow suit
  enableJemalloc ? true,
  rust-jemalloc-sys,
  enableLiburing ? stdenv.hostPlatform.isLinux,
  liburing,
}:
let
  rust-jemalloc-sys' = rust-jemalloc-sys.override {
    unprefixed = !stdenv.hostPlatform.isDarwin;
  };
  rocksdb' = rocksdb.override {
    inherit enableLiburing;
    # rocksdb does not support prefixed jemalloc, which is required on darwin
    enableJemalloc = enableJemalloc && !stdenv.hostPlatform.isDarwin;
    jemalloc = rust-jemalloc-sys';
  };
in
rustPlatform.buildRustPackage rec {
  pname = "conduwuit";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "girlbossceo";
    repo = "conduwuit";
    rev = "v${version}";
    hash = "sha256-ut3IWEueNR/hT7NyGfuK5IYtppC6ArSoJdEfFuD/0vE=";
  };

  cargoHash = "sha256-L0UvJ5ZyEk/hZobkB21u6cfPCeRwhDl+07aWcQEOgYw=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    bzip2
    zstd
  ]
  ++ lib.optional enableJemalloc rust-jemalloc-sys'
  ++ lib.optional enableLiburing liburing;

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
    ROCKSDB_INCLUDE_DIR = "${rocksdb'}/include";
    ROCKSDB_LIB_DIR = "${rocksdb'}/lib";
  };

  buildNoDefaultFeatures = true;
  # See https://github.com/girlbossceo/conduwuit/blob/main/src/main/Cargo.toml
  # for available features.
  # We enable all default features except jemalloc and io_uring, which
  # we guard behind our own (default-enabled) flags.
  buildFeatures = [
    "brotli_compression"
    "element_hacks"
    "gzip_compression"
    "release_max_log_level"
    "sentry_telemetry"
    "systemd"
    "zstd_compression"
  ]
  ++ lib.optional enableJemalloc "jemalloc"
  ++ lib.optional enableLiburing "io_uring";

  passthru = {
    updateScript = nix-update-script { };
    tests = {
      version = testers.testVersion {
        inherit version;
        package = conduwuit;
      };
    };
  };

  meta = {
    description = "Matrix homeserver written in Rust, forked from conduit";
    homepage = "https://conduwuit.puppyirl.gay/";
    changelog = "https://github.com/girlbossceo/conduwuit/releases/tag/v${version}";
    license = lib.licenses.asl20;
    knownVulnerabilities = [
      "On April 11, 2025, the conduwuit project officially ceased development"
    ];
    maintainers = with lib.maintainers; [ niklaskorz ];
    # Not a typo, conduwuit is a drop-in replacement for conduit.
    mainProgram = "conduit";
  };
}
