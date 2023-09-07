{ lib

, vimPlugins

, linkFarm
, symlinkJoin
, runCommand
, writeShellApplication
, writeText
, writeShellScript

, makeWrapper
, makeOverridable

, wrapNeovim
, stdenv

}:

let

  isDir = path:
    let
      drv = runCommand "isDir" { } ''
        function puts()
        {
          echo -n "$@"  >> $out
        }

        PT="${path}";
        if [ -L "$PT" ]; then
          PT="$(readlink "$PT")"
        fi

        if [ -d "$PT" ]; then
          if [ -f "$PT/init.lua" ]; then
            puts "dir"
          else
            puts "'$PT' directory does not have init.lua file "
            puts "which is required for NvChad"
          fi
        elif [ -f "$PT" ]; then
          puts "file"
        else
          puts "'$PT' neither directory nor file which is required for NvChad"
        fi
      '';
      res = builtins.readFile drv;
    in
    if res == "dir" then
      true
    else if res == "file" then
      false
    else
      throw res;

  stringToLink = text:
    let
      drv = writeText "init.lua" text;
    in
    pathToLink (builtins.toPath text);

  pathToLink = path:
    {
      name =
        if isDir path then
          "lua/custom"
        else
          "lua/custom/init.lua";
      inherit path;
    };

  customToLink = custom: with builtins;
    let
      t = typeOf custom;
      wrongCustom = throw "";
    in
    if t == "null" then
      [ ]
    else if t == "path" then
      [ (pathToLink custom) ]
    else if t == "string" then
      [ (stringToLink custom) ]
    else if t == "set" then
      let
        path =
          if lib.attrsets.isDerivation custom then
            toPath custom
          else
            wrongCustom;
      in
      [ (pathToLink path) ]
    else wrongCustom;

  config =
    custom: linkFarm "neovim-config" ([
      {
        name = "init.lua";
        path = ../init.lua;
      }
      {
        name = "lua/core";
        path = ../lua/core;
      }
      {
        name = "lua/plugins";
        path = ../lua/plugins;
      }
    ] ++ (customToLink custom));

in
neovim:
{ custom ? null
, viAlias ? false
, vimAlias ? false
, withPython3 ? true
, withNodeJs ? false
, withRuby ? false
, runtimeInputs ? [ ]
, extraMakeWrapperArgs ? ""
}:
let
  conf = config custom;
  inputs = lib.makeBinPath (runtimeInputs ++ [ stdenv.cc ]);
  # This will run each time nvim started to make sure the config from nix is
  # updated but still will left runtime (e.g. lazy lock) to keep untouched
  prepareConfigDir = writeShellScript "nevimPrepareConfigDir" ''
    [ -z "$HOME" ] && exit;
    mkdir -p $HOME/.config/nvim/lua
    function mkLink() {
      local dst="${conf}/$1"
      if [ -e "$dst" ]; then
        rm -f "$HOME/.config/nvim/$1"
        ln -sf "$dst" "$HOME/.config/nvim/$1"
      fi
    }
    mkLink init.lua
    mkLink lua/core
    mkLink lua/plugins
    mkLink lua/custom
  '';
in
(wrapNeovim neovim {
  extraMakeWrapperArgs = ''                                                    \
    --add-flags "-u ${conf}/init.lua"                                          \
    --add-flags "--cmd ':set rtp+=${conf}'"                                    \
    --prefix LUA_PATH ";" "${conf}/lua/?.lua"                                  \
    --set DISABLE_MASON "ON"                                                   \
    --prefix PATH ":" ${inputs}                                                \
    --run '${prepareConfigDir}' '' + extraMakeWrapperArgs;
  inherit viAlias vimAlias withPython3 withNodeJs withRuby;
})
