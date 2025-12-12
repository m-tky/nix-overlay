{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "sklearn-genetic";
  version = "0.6.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-1bViPln+tnIs9bsDuRTck7jZOz3/kQPluYJSQSgbUzg=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    deap
    multiprocess
    numpy
    scikit-learn
  ];

  pythonImportsCheck = [
    "sklearn_genetic"
  ];

  meta = {
    description = "Genetic feature selection module for scikit-learn";
    homepage = "https://pypi.org/project/sklearn-genetic/";
    license = lib.licenses.unfree; # FIXME: nix-init did not find a license
    maintainers = with lib.maintainers; [ ];
    mainProgram = "sklearn-genetic";
  };
}
