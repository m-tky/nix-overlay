{
  description = "Custom data-science development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    data-science = {
      url = "github:m-tky/nix-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, data-science, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pythonPackages = data-science.lib.${system}.pythonPackages;

          myEnvironment = data-science.lib.${system}.mkDataSciencePackageWith {
            # Add packages from `pythonPackages`, for example:
            extraPackages = [
              # pythonPackages.polars
            ];

            # Remove packages from the standard environment, for example:
            excludePackages = [
              # pythonPackages.torch
              # pythonPackages.torchvision
            ];
          };
        in {
          default = pkgs.mkShell {
            packages = [ myEnvironment ];
          };
        }
      );
    };
}
