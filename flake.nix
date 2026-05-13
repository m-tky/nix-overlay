{
  description = "A flake for managing custom packages and development environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
    {
      lib = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          mkPythonEnv =
            extraPackages:
            let
              japanize-matplotlib = pkgs.python312Packages.callPackage ./pkgs/japanize-matplotlib.nix { };
            in
            pkgs.python312.withPackages (ps: [
              japanize-matplotlib
              ps.ipython
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
            ] ++ extraPackages);
        in
        { inherit mkPythonEnv; }
      );

      devShells = forAllSystems (
        system:
        let
          isLinux = nixpkgs.lib.hasSuffix "linux" system;

          mkPkgs =
            cudaSupport:
            import nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
                inherit cudaSupport;
              };
            };

          mkPythonEnv =
            pkgs: extraPackages:
            let
              japanize-matplotlib = pkgs.python312Packages.callPackage ./pkgs/japanize-matplotlib.nix { };
            in
            pkgs.python312.withPackages (ps: [
              japanize-matplotlib
              ps.ipython
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
            ] ++ extraPackages);

          pkgsCpu = mkPkgs false;
          pythonCpu = mkPythonEnv pkgsCpu [];
        in
        {
          dataAnalysis = pkgsCpu.mkShell {
            packages = [ pythonCpu ];
          };

          default = pkgsCpu.mkShell {
            packages = [ ];
          };
        }
        // nixpkgs.lib.optionalAttrs isLinux (
          let
            pkgsCuda = mkPkgs true;
            pythonCuda = mkPythonEnv pkgsCuda [];
          in
          {
            dataAnalysisCuda = pkgsCuda.mkShell {
              packages = [ pythonCuda ];
              shellHook = ''
                echo "CUDA-enabled dataAnalysis shell"
              '';
            };
          }
        )
      );
    };
}
