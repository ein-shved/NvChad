{ config, lib, pkgs, ... }:
let
  wrapNvChad = pkgs.callPackage ./wrapper.nix { };
  cfg = config.programs.neovim;
  ccfg = cfg.nvchad;
in
{
  options = {
    programs.neovim.nvchad = {
      enable = lib.mkEnableOption "NvChad configuration for neovim";
      custom = lib.mkOption {
        type = with lib.types; either (nullOr str) (either package path);
        default = null;
        description = ''
          A text or package of custom NvChad configuration in lua
        '';
      };
      runtimeInputs = lib.mkOption {
        type = with lib.types; listOf package;
        default = [];
        description = ''
          Extra runtime inputs for editor. E.g. `pkgs.clang-tools`
        '';
      };
      extraMakeWrapperArgs = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = ''
          Extra argumets to makeWrapper script for neovim
        '';
      };
    };
  };

  config = with lib; mkIf ccfg.enable {
    programs.neovim.enable = mkForce false;
    environment.systemPackages = [
      # TODO(Shvedov) Find a way to override cfg.finalPackge read-only option
      (wrapNvChad cfg.package {
        inherit (cfg) viAlias vimAlias withPython3 withNodeJs withRuby;
        inherit (ccfg) custom runtimeInputs extraMakeWrapperArgs;
      })
    ];
    environment.variables.EDITOR = mkIf cfg.defaultEditor (mkOverride 900 "nvim");

    environment.etc = listToAttrs (attrValues (mapAttrs
      (name: value: {
        name = "xdg/nvim/${name}";
        value = removeAttrs
          (value // {
            target = "xdg/nvim/${value.target}";
          })
          (optionals (isNull value.source) [ "source" ]);
      })
      cfg.runtime));
  };
}
