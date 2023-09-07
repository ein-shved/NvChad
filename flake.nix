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
          neovim = pkgs.callPackage ./nix {};
        in
        {
          packages = {
            inherit neovim;
            default = neovim;
          };
        });
      output = { inherit modules; } // packages;
    in
    output;
}
