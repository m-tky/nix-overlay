{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "setuptools-scm";
  version = "8.3.1";
  pyproject = true;

  src = fetchPypi {
    pname = "setuptools_scm";
    inherit version;
    hash = "sha256-PVVekrddrNA30yuv35T5evUeoprox7I0z5S3pb0kKmM=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.tomli
  ];

  dependencies = with python3.pkgs; [
    importlib-metadata
    packaging
    setuptools
    tomli
    typing-extensions
  ];

  optional-dependencies = with python3.pkgs; {
    docs = [
      entangled-cli
      mkdocs
      mkdocs-entangled-plugin
      mkdocs-include-markdown-plugin
      mkdocs-material
      mkdocstrings
      pygments
    ];
    rich = [
      rich
    ];
    test = [
      build
      pytest
      rich
      typing-extensions
      wheel
    ];
  };

  pythonImportsCheck = [
    "setuptools_scm"
  ];

  meta = {
    description = "The blessed package to manage your versions by scm tags";
    homepage = "https://pypi.org/project/setuptools-scm/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "setuptools-scm";
  };
}
