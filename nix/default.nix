{ vimPlugins
, linkFarm
, runCommand
, neovim-unwrapped
, makeWrapper
, writeShellApplication
}:

let
  plugins = with vimPlugins;
    [
      # plugins here
      #      undotree gitsigns-nvim
      #      plenary-nvim
    ];

  pack = linkFarm "neovim-plugins"
    (map
      (pkg:
        {
          name = "pack/${pkg.pname}/start/${pkg.pname}";
          path = toString pkg;
        })
      plugins);

  conf = linkFarm "neovim-config" [
    {
      name = "init.lua";
      path = ../init.lua;
    }
    {
      name = "lua";
      path = ../lua;
    }
  ];

in
runCommand "nvim"
{
  nativeBuildInputs = [ makeWrapper ];
}
  ''
    mkdir -p "$out"
    makeWrapper '${neovim-unwrapped}/bin/nvim' "$out/bin/nvim" \
      --add-flags "-u ${conf}/init.lua" \
      --add-flags "--cmd ':set rtp+=${conf}'" \
      --set LUA_PATH "./?.lua;./?.lc;/usr/local/?/init.lua;${conf}/lua/?.lua"
  ''
