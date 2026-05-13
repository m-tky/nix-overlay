{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
  matplotlib,
}:

buildPythonPackage rec {
  pname = "japanize-matplotlib";
  version = "1.1.3";

  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-6J59nhCYIJYmUOWaEwQDtZszkV/eOHGiZaWJHZv14Hk=";
  };

  build-system = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    matplotlib
  ];

  doCheck = false;

  meta = with lib; {
    description = "Matplotlib Japanese font support";
    homepage = "https://pypi.org/project/japanize-matplotlib/";
    license = licenses.mit;
  };
}
