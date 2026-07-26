{
  description = "Reusable data-science Python environments and development shells";

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

          # Kept for callers already consuming the original Python environment.
          mkPythonEnv =
            extraPackages: import ./pkgs/python-env.nix { pkgs = mkPkgs false; inherit extraPackages; };

          mkPythonEnvWith =
            {
              extraPackages ? [ ],
              excludePackages ? [ ],
            }:
            import ./pkgs/python-env.nix {
              pkgs = mkPkgs false;
              inherit extraPackages excludePackages;
            };

          pythonPackages = (mkPkgs false).python312Packages;

          mkDataSciencePackage =
            extraPackages:
            import ./pkgs/data-science.nix {
              pkgs = mkPkgs false;
              inherit extraPackages;
            };

          mkDataSciencePackageWith =
            {
              extraPackages ? [ ],
              excludePackages ? [ ],
              name ? "data-science",
            }:
            import ./pkgs/data-science.nix {
              pkgs = mkPkgs false;
              inherit extraPackages excludePackages name;
            };
        in
        {
          inherit mkPythonEnv mkPythonEnvWith mkDataSciencePackage mkDataSciencePackageWith pythonPackages;
        }
        # CUDA-enabled builder; only valid on Linux.
        // nixpkgs.lib.optionalAttrs isLinux {
          mkPythonEnvCuda =
            extraPackages: import ./pkgs/python-env.nix { pkgs = mkPkgs true; inherit extraPackages; };
          mkPythonEnvCudaWith =
            {
              extraPackages ? [ ],
              excludePackages ? [ ],
            }:
            import ./pkgs/python-env.nix {
              pkgs = mkPkgs true;
              inherit extraPackages excludePackages;
            };
          mkDataSciencePackageCuda =
            extraPackages:
            import ./pkgs/data-science.nix {
              pkgs = mkPkgs true;
              inherit extraPackages;
              name = "data-science-cuda";
            };
          mkDataSciencePackageCudaWith =
            {
              extraPackages ? [ ],
              excludePackages ? [ ],
              name ? "data-science-cuda",
            }:
            import ./pkgs/data-science.nix {
              pkgs = mkPkgs true;
              inherit extraPackages excludePackages name;
            };
          pythonPackagesCuda = (mkPkgs true).python312Packages;
        }
      );

      # Use `inputs.data-science.overlays.default` to add `data-science` to a
      # consumer's package set.  It deliberately follows the consumer's
      # nixpkgs revision and Python package set.
      overlays.default = final: _prev: {
        data-science = import ./pkgs/data-science.nix { pkgs = final; };
      };

      packages = forAllSystems (
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
          pkgsCpu = mkPkgs false;
          dataScience = import ./pkgs/data-science.nix { pkgs = pkgsCpu; };
        in
        {
          "data-science" = dataScience;
          default = dataScience;
        }
        // nixpkgs.lib.optionalAttrs isLinux {
          "data-science-cuda" = import ./pkgs/data-science.nix {
            pkgs = mkPkgs true;
            name = "data-science-cuda";
          };
        }
      );

      templates.data-science = {
        path = ./templates/data-science;
        description = "Customizable data-science development shell";
        welcomeText = ''
          Run `nix develop` to enter the data-science environment.
          Edit `flake.nix` to add or exclude Python libraries.
        '';
      };

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

          pkgsCpu = mkPkgs false;
          dataScience = import ./pkgs/data-science.nix { pkgs = pkgsCpu; };
        in
        {
          dataAnalysis = pkgsCpu.mkShell {
            packages = [ dataScience ];
          };

          default = pkgsCpu.mkShell {
            packages = [ ];
          };
        }
        // nixpkgs.lib.optionalAttrs isLinux (
          let
            pkgsCuda = mkPkgs true;
            dataScienceCuda = import ./pkgs/data-science.nix {
              pkgs = pkgsCuda;
              name = "data-science-cuda";
            };
          in
          {
            dataAnalysisCuda = pkgsCuda.mkShell {
              packages = [ dataScienceCuda ];
              shellHook = ''
                echo "CUDA-enabled dataAnalysis shell"
              '';
            };
          }
        )
      );
    };
}
