# Data-science Nix flake

This flake provides a reproducible Python 3.12 environment for data-science
work: JupyterLab, NumPy, pandas, SciPy, scikit-learn, visualization tools,
gradient-boosting libraries, PyTorch, and Japanese matplotlib support.

## Use directly

Run an ephemeral shell containing the environment:

```sh
nix shell github:OWNER/nix-overlay#data-science
jupyter lab
```

Or enter the development shell:

```sh
nix develop github:OWNER/nix-overlay#dataAnalysis
```

On Linux, the CUDA variant is also available as
`#data-science-cuda` and `#dataAnalysisCuda`.

## Consume from another flake

Add this flake as an input, then install its package:

```nix
{
  inputs.data-science.url = "github:m-tky/nix-overlay";

  outputs = { self, nixpkgs, data-science, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      packages.${system}.default = data-science.packages.${system}.default;
    };
}
```

To make it available through your package set instead, use the overlay:

```nix
pkgs = import nixpkgs {
  inherit system;
  overlays = [ data-science.overlays.default ];
};

# pkgs.data-science
```

To add or remove libraries, use the configurable builder. Package references
come from the flake's pinned nixpkgs Python package set:

```nix
myEnvironment = data-science.lib.${system}.mkDataSciencePackageWith {
  extraPackages = [
    data-science.lib.${system}.pythonPackages.polars
  ];
  excludePackages = [
    data-science.lib.${system}.pythonPackages.torch
    data-science.lib.${system}.pythonPackages.torchvision
  ];
};
```

`mkPythonEnv` remains available for compatibility when the raw Python
environment rather than the named `data-science` package is required. Its
configurable counterpart is `mkPythonEnvWith`; CUDA equivalents have a `Cuda`
suffix on Linux.

## Use a custom environment with `nix develop`

Define the environment in the consuming flake's `devShells`.  The `follows`
setting keeps the Python package references compatible with the consumer's
nixpkgs input.

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    data-science = {
      url = "github:m-tky/nix-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, data-science, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      myEnvironment = data-science.lib.${system}.mkDataSciencePackageWith {
        extraPackages = [
          data-science.lib.${system}.pythonPackages.polars
        ];
        excludePackages = [
          data-science.lib.${system}.pythonPackages.torch
          data-science.lib.${system}.pythonPackages.torchvision
        ];
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [ myEnvironment ];
      };
    };
}
```

Run `nix develop` in that project, then start tools such as `jupyter lab`.
On Linux, use `mkDataSciencePackageCudaWith` for a CUDA-enabled environment.

## Start from a template

Create a project containing the customizable `nix develop` configuration:

```sh
nix flake init -t github:m-tky/nix-overlay#data-science
nix develop
```

Edit the generated `flake.nix` to change `extraPackages` or
`excludePackages`.
