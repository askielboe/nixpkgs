{
  lib,
  fetchFromGitHub,
  git,
  python3,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "ggshield";
  version = "1.40.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "GitGuardian";
    repo = "ggshield";
    tag = "v${version}";
    hash = "sha256-Y42MBRyjPljUAGTwhH2FS8drUAceuJse8Qd1GbctWQs=";
  };

  pythonRelaxDeps = true;

  build-system = with python3.pkgs; [ pdm-backend ];

  dependencies = with python3.pkgs; [
    appdirs
    charset-normalizer
    click
    cryptography
    marshmallow
    marshmallow-dataclass
    oauthlib
    platformdirs
    pygitguardian
    pyjwt
    python-dotenv
    pyyaml
    requests
    rich
    truststore
  ];

  nativeCheckInputs = [
    git
  ]
  ++ (with python3.pkgs; [
    jsonschema
    pyfakefs
    pytest-factoryboy
    pytest-mock
    pytest-voluptuous
    pytestCheckHook
    snapshottest
    vcrpy
  ]);

  pythonImportsCheck = [ "ggshield" ];

  disabledTestPaths = [
    # Don't run functional tests
    "tests/functional/"
    "tests/unit/cmd/honeytoken"
    "tests/unit/cmd/scan/"
    "tests/test_factories.py"
  ];

  disabledTests = [
    # No TLS certificate, no .git folder, etc.
    "test_cache_catches"
    "test_is_git_dir"
    "test_is_valid_git_commit_ref"
    "test_check_git_dir"
    "test_does_not_fail_if_cache"
    # Encoding issues
    "test_create_files_from_paths"
    "test_file_decode_content"
    "test_file_is_longer_than_does_not_read_utf8_file"
    "test_file_is_longer_using_8bit_codec"
    "test_generate_files_from_paths"
    # Nixpkgs issue
    "test_get_file_sha_in_ref"
  ];

  meta = with lib; {
    description = "Tool to find and fix various types of hardcoded secrets and infrastructure-as-code misconfigurations";
    homepage = "https://github.com/GitGuardian/ggshield";
    changelog = "https://github.com/GitGuardian/ggshield/blob/${version}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ fab ];
    mainProgram = "ggshield";
  };
}
