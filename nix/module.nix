{ config, lib, pkgs, ... }:
let
  neovim = pkgs.callPackage ./defalut.nix {};
in
{

  nixpkgs.overlays = [ (self: super: { neovim = neovim; }) ];

  # nix build -f '<nixpkgs/nixos>' config.programs.neovim.package for testing
  programs.neovim.package = neovim;
}
