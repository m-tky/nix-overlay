{
  description = "A factory flake for creating UV-based Python devShells with FHS environment.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem
      (
        system:
        let
          pkgs = import nixpkgs { inherit system; };

          # UV DevShellを生成する内部関数
          mkUVPythonDevShell =
            {
              extraPkgs ? [ ],
              runCommand ? "zsh",
            }:
            (pkgs.buildFHSEnv {
              name = "uv-python-env";

              # FHS環境内に含めるターゲットパッケージ
              targetPkgs =
                pkgs:
                (with pkgs; [
                  python3
                  uv # UV tool for fast dependency management
                  cmake
                  ninja
                  gcc
                ])
                ++ extraPkgs;

              # シェルが起動したときに実行されるスクリプト
              runScript = "${pkgs.writeShellScriptBin "runScript" (''
                set -e
                # .venv ディレクトリを確認し、存在しなければ UV を使って作成
                test -d .venv || ${pkgs.uv}/bin/uv venv
                # プロジェクトの Python バージョン設定ファイルを初期化
                test -f .python-version || ${pkgs.uv}/bin/uv init . 
                # 仮想環境をアクティベート
                source .venv/bin/activate
                set +e
                # 指定されたコマンドを実行 (デフォルトは bash)
                exec ${runCommand}
              '')}/bin/runScript";
            }).env;

        in
        {
          # 【重要】`devShell` トップレベルアトリビュートを定義します。
          # これは、このFlakeが提供するデフォルトの開発シェルです。
          devShell = mkUVPythonDevShell {
            extraPkgs = with pkgs; [ git ];
          };

          # 以前の `lib.mkUVPythonDevShell` 関数は、この構造では外部にはエクスポートされません。
          # (devShellsやlibなど、複数のトップレベルアトリビュートが必要な場合は、
          # `flake-utils.lib.eachDefaultSystem`の外側で定義する必要があります。)
        }
      ).devShells; # ★ flake-utils.lib.eachDefaultSystem の結果から devShells を取り出し、
  # それを devShell のトップレベルアトリビュートとしてリネームして出力します。
}
