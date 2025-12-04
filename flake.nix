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

      # 各システムごとに pkgs を生成するためのヘルパー関数
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

    in
    {
      overlays.default =
        final: prev:
        let
          lib = final.lib;
          python3 = final.python3;
          fetchPypi = final.fetchPypi;

          japanize-matplotlibOverride = import ./pkgs/japanize-matplotlib.nix {
            inherit lib python3 fetchPypi;
          };

        in
        {
          python3 = prev.python3.override {
            packageOverrides = pyfinal: pyprev: {
              japanize-matplotlib = japanize-matplotlibOverride;
            };
          };
        };

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };

          # Python 環境の定義
          dataAnalysisPython = pkgs.python3.withPackages (ps: [
            ps.ipython
            ps.ipykernel
            ps.jupyter-client
            ps.jupyter

            ps.numpy
            ps.pandas
            ps.matplotlib
            ps.japanize-matplotlib
            ps.scipy
            ps.seaborn
            ps.plotly
            ps.scikit-learn
            ps.openpyxl
            ps.lightgbm
            ps.optuna
            ps.tabulate
            # ps.ydata-profiling
          ]);
        in
        {
          dataAnalysis = pkgs.mkShell {
            packages = [
              dataAnalysisPython
              # pkgs.another
            ];
          };

          # (例) リポジトリ管理用のデフォルトシェル
          default = pkgs.mkShell {
            packages = [
              pkgs.bashInteractive
              pkgs.git
            ];
          };
        }
      );

      # devShell = forAllSystems (system: self.devShells.${system}.default);
    };
}
