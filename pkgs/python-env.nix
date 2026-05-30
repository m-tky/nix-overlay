# Shared Python environment definition.
# Single source of truth for the package list, consumed by both
# `lib.mkPythonEnv` and the devShells in flake.nix.
{
  pkgs,
  extraPackages ? [ ],
}:
let
  japanize-matplotlib = pkgs.python312Packages.callPackage ./japanize-matplotlib.nix { };
in
pkgs.python312.withPackages (
  ps:
  [
    japanize-matplotlib
    ps.tqdm
    ps.ipython
    ps.ipykernel
    ps.jupyterlab
    ps.statsmodels
    ps.deap
    ps.numpy
    ps.pandas
    ps.matplotlib
    ps.scipy
    ps.seaborn
    ps.plotly
    ps.shap
    ps.scikit-learn
    ps.openpyxl
    ps.lightgbm
    ps.xgboost
    ps.catboost
    ps.optuna
    ps.tabulate
    ps.torch
    ps.torchvision
  ]
  ++ extraPackages
)
