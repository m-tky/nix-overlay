{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "setuptools";
  version = "79.0.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-EoznuPM8MHn9GwZ+y7QFGmboUm57ZfbOwHXfxlDd+og=";
  };

  optional-dependencies = with python3.pkgs; {
    check = [
      pytest-checkdocs
      pytest-ruff
      ruff
    ];
    core = [
      importlib-metadata
      jaraco-functools
      jaraco-text
      more-itertools
      packaging
      platformdirs
      tomli
      wheel
    ];
    cover = [
      pytest-cov
    ];
    doc = [
      furo
      jaraco-packaging
      jaraco-tidelift
      pygments-github-lexers
      pyproject-hooks
      rst-linker
      sphinx
      sphinx-favicon
      sphinx-inline-tabs
      sphinx-lint
      sphinx-notfound-page
      sphinx-reredirects
      sphinxcontrib-towncrier
      towncrier
    ];
    enabler = [
      pytest-enabler
    ];
    test = [
      build
      filelock
      ini2toml
      jaraco-develop
      jaraco-envs
      jaraco-path
      jaraco-test
      packaging
      pip
      pyproject-hooks
      pytest
      pytest-home
      pytest-perf
      pytest-subprocess
      pytest-timeout
      pytest-xdist
      tomli-w
      virtualenv
      wheel
    ];
    type = [
      importlib-metadata
      jaraco-develop
      mypy
      pytest-mypy
    ];
  };

  pythonImportsCheck = [
    "setuptools"
  ];

  meta = {
    description = "Easily download, build, install, upgrade, and uninstall Python packages";
    homepage = "https://pypi.org/project/setuptools/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "setuptools";
  };
}
