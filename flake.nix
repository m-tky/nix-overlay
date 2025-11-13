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

      # 各システム用の nixpkgs のパッケージセット
      pkgsFor = system: nixpkgs.legacyPackages.${system};

      neopyterFunction = import ./pkgs/neopyter.nix;
      # ex)
      # anotherPkgFunction = import ./pkgs/another.nix;

    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          # ここで {pkgs} を渡して関数を呼び出し、ビルドする
          neopyter = neopyterFunction { inherit pkgs; };
          # another = anotherPkgFunction { inherit pkgs; };
        }
      );

      overlays.default =
        final: prev:
        let
          # lib = final.lib;
          # python3 = final.python3;
          # fetchPypi = final.fetchPypi;
          # setuptoolsOverride = import ./pkgs/setuptools.nix {
          #   inherit lib python3 fetchPypi;
          # };
          # setuptools-scmOverride = import ./pkgs/setuptools-scm.nix {
          #   inherit lib python3 fetchPypi;
          # };

        in
        {
          python312 = prev.python312.override {
            packageOverrides = pyfinal: pyprev: {
              neopyter = neopyterFunction { pkgs = final; };
              visions = pyprev.visions.overridePythonAttrs (old: {
                propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [ pyfinal.imagehash ];
                doCheck = false; # テスト無効化
              });
              # setuptools = setuptoolsOverride;
              # setuptools-scm = setuptools-scmOverride;
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
          dataAnalysisPython = pkgs.python312.withPackages (ps: [
            ps.jupyterlab
            ps.numpy
            ps.pandas
            ps.matplotlib
            ps.scipy
            ps.seaborn
            ps.plotly
            ps.scikit-learn
            ps.neopyter
            ps.openpyxl
            ps.ipython
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
