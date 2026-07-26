# A named, installable package that exposes the shared data-science Python
# environment.  `buildEnv` gives consumers a stable package name while keeping
# the Python environment itself as the single source of truth.
{
  pkgs,
  extraPackages ? [ ],
  excludePackages ? [ ],
  name ? "data-science",
}:
pkgs.buildEnv {
  inherit name;
  paths = [
    (import ./python-env.nix {
      inherit pkgs extraPackages excludePackages;
    })
  ];

  meta = {
    description = "Python 3.12 environment for data-science workflows";
    platforms = pkgs.lib.platforms.all;
  };
}
