{ pkgs, ... }:

pkgs.python3Packages.buildPythonPackage rec {
  pname = "neopyter";
  version = "0.3.2";

  src = pkgs.python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "w5gOSKdRc163UPFmrf/SGtkKRU5C2KOGb6aR6RT0FiM=";
  };

  pyproject = true;

  nativeBuildInputs = [
    pkgs.python312Packages.hatchling
    pkgs.python312Packages.hatch-jupyter-builder
    pkgs.python312Packages.hatch-nodejs-version
  ];

  # propagatedBuildInputs = [
  #   pkgs.python312Packages.jupyterlab
  #   pkgs.python312Packages.pynvim
  # ];

  doCheck = true;
}
