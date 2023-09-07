{
  inputs = {
    flake-utils.url = github:numtide/flake-utils;
  };
  outputs = { self, nixpkgs, flake-utils }:
    let
      modules = [
        ./nix/module.nix
      ];
      packages = flake-utils.lib.eachDefaultSystem
        (system:
          let
            pkgs = import nixpkgs { inherit system; };
            wrapNvChad = pkgs.callPackage ./nix/wrapper.nix { };
            neovim = wrapNvChad pkgs.neovim-unwrapped { };
          in
          {
            packages = {
              inherit neovim wrapNvChad;
              default = neovim;
            };
          });
    in
    { inherit modules; } // packages;
}
