{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "jupyterlab-vim";
  version = "4.1.4";
  pyproject = true;

  src = fetchPypi {
    pname = "jupyterlab_vim";
    inherit version;
    hash = "sha256-q/KJGq+zLwy5StmDIa5+vL4Mq+Uj042A1WnApQuFIlo=";
  };

  build-system = [
    python3.pkgs.hatch-nodejs-version
    python3.pkgs.hatchling
    python3.pkgs.jupyterlab
  ];

  dependencies = with python3.pkgs; [
    jupyterlab
  ];

  pythonImportsCheck = [
    "jupyterlab_vim"
  ];

  meta = {
    description = "Code cell vim bindings";
    homepage = "https://pypi.org/project/jupyterlab-vim/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "jupyterlab-vim";
  };
}
