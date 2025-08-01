{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools-generate,
  setuptools-scm,
  colorama,
  jinja2,
  jsonschema,
  pygls,
  tree-sitter,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "lsp-tree-sitter";
  version = "0.0.17";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "neomutt";
    repo = "lsp-tree-sitter";
    tag = version;
    hash = "sha256-4DQzHdii2YS/Xg6AdT/kXC/8B88ZQaLgUf2oWoOthV8=";
  };

  build-system = [
    setuptools-generate
    setuptools-scm
  ];

  dependencies = [
    colorama
    jinja2
    jsonschema
    pygls
    tree-sitter
  ];
  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "lsp_tree_sitter" ];

  meta = with lib; {
    description = "A library to create language servers";
    homepage = "https://github.com/neomutt/lsp-tree-sitter";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ doronbehar ];
    # https://github.com/neomutt/lsp-tree-sitter/issues/4
    broken = true;
  };
}
