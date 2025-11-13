{
  description = "A flake for managing custom packages and development environments";

  inputs = {
    # nixpkgs をインプットとして定義
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      # サポートするシステム（アーキテクチャ）のリスト
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
      # --- 1. パッケージ定義 (nix build 用) ---
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

      # `nix build` (引数なし) のデフォルトパッケージ
      # defaultPackage = forAllSystems (system: self.packages.${system}.another);

      # --- 2. Overlay (パッケージの再利用) ---
      # (★ 変更点)
      overlays.default = final: prev: {

        # --- A. 通常のパッケージ (pkgs のトップレベルに追加) ---
        # another = anotherPkgFunction { pkgs = final; };

        python311 = prev.python311.override {
          packageOverrides = pyfinal: pyprev: {
            neopyter = neopyterFunction { pkgs = final; };
          };
        };
      };

      # --- 3. 開発環境 (複数) ---
      devShells = forAllSystems (
        system:
        let
          # (★ 変更なし)
          # この Flake 自身が開発環境で overlay を使う
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };

          # Python 環境の定義
          dataAnalysisPython = pkgs.python311.withPackages (ps: [
            ps.uv
            # ps.numpy
            # ps.pandas
            # ps.pillow
            # ps.scipy
            # ps.torch
            # ps.torchvision
            # ps.jupyterlab
            # ps.matplotlib
            # ps.seaborn
            # ps.plotly
            # ps.scikit-learn
            # ps.neopyter
            # ps.openpyxl
            # ps.ipython
            # ps.ydata-profiling
          ]);
        in
        {
          dataAnalysis = pkgs.mkShell {
            packages = [
              dataAnalysisPython
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
