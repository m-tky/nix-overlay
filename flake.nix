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
            extraPackages: import ./pkgs/python-env.nix { pkgs = mkPkgs false; inherit extraPackages; };
        in
        {
          inherit mkPythonEnv;
        }
        # CUDA-enabled builder; only valid on Linux.
        // nixpkgs.lib.optionalAttrs isLinux {
          mkPythonEnvCuda =
            extraPackages: import ./pkgs/python-env.nix { pkgs = mkPkgs true; inherit extraPackages; };
        }
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

          mkPythonEnv = pkgs: extraPackages: import ./pkgs/python-env.nix { inherit pkgs extraPackages; };

          pkgsCpu = mkPkgs false;
          pythonCpu = mkPythonEnv pkgsCpu [ ];
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
            pythonCuda = mkPythonEnv pkgsCuda [ ];
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
