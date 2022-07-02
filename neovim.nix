{ embed ? false
, bat
, black
, cargo
, clang
, efm-langserver
, fd
, git
, go-tools
, go_1_18
, gofumpt
, gopls
, jq
, lib
, neovim-unwrapped
, nixpkgs-fmt
, nodePackages
, nodejs
, pyright
, python3
, python3Packages
, ripgrep
, rnix-lsp
, rust-analyzer
, rustc
, rustfmt
, shellcheck
, shfmt
, sumneko-lua-language-server
, tree-sitter
, vimPlugins
, wrapNeovim
, zig
, zls
}:
let
  configure = {
    customRC = ''
      lua vim.g.embed = ${if embed then "1" else "0"}
    '';
    packages.plugins = with vimPlugins; {
      start = [
        (nvim-treesitter.withPlugins (_: tree-sitter.allGrammars))
        comment-nvim
        jmbaur-settings
        nvim-autopairs
        nvim-lspconfig
        nvim-treesitter-textobjects
        snippets-nvim
        typescript-vim
        vim-cue
        vim-nix
        vim-repeat
        vim-sleuth
        vim-surround
        vim-terraform
        vim-unimpaired
        zig-vim
      ] ++ (if (!embed) then [
        jared-vim
        nvim-lastplace
        telescope-nvim
        telescope-ui-select-nvim
        vim-better-whitespace
        vim-dirvish
        vim-dispatch
        vim-eunuch
        vim-fugitive
        vim-rsi
      ] else [ ]);
      opt = (if (!embed) then [
        editorconfig-vim
        xterm-color-table
      ] else [ ]);
    };
  };
  extraMakeWrapperArgs =
    let
      binPath = lib.makeBinPath [
        bat
        cargo
        clang
        efm-langserver
        fd
        git
        go-tools
        go_1_18
        gofumpt
        gopls
        jq
        nixpkgs-fmt
        nodePackages.prettier
        nodePackages.typescript
        nodePackages.typescript-language-server
        nodejs
        pyright
        python3
        python3Packages.black
        python3Packages.isort
        ripgrep
        rnix-lsp
        rust-analyzer
        rustc
        rustfmt
        shellcheck
        shfmt
        sumneko-lua-language-server
        tree-sitter
        zig
        zls
      ];
    in
    ''
      --suffix PATH : ${binPath} \
      --set SUMNEKO_ROOT_PATH ${sumneko-lua-language-server}
    '';
in
wrapNeovim neovim-unwrapped {
  vimAlias = true;
  inherit configure extraMakeWrapperArgs;
}
