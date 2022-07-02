{
  description = "Portable neovim setup";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit.url = "github:cachix/pre-commit-hooks.nix";
    jared-vim = {
      url = "github:jmbaur/jared.vim";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , pre-commit
    , jared-vim
    , ...
    }: {
      overlays.default = final: prev:
        let
          standalone = prev.callPackage ./neovim.nix { embed = false; };
          embed = prev.callPackage ./neovim.nix { embed = true; };
        in
        {
          vimPlugins = prev.vimPlugins // {
            jared-vim = prev.vimUtils.buildVimPlugin rec {
              name = "jared-vim";
              src = jared-vim;
            };
            jmbaur-settings = prev.vimUtils.buildVimPlugin {
              name = "jmbaur-settings";
              src = builtins.path { path = ./settings; };
            };
          };
          neovim = standalone;
          neovim-embed = embed;
        };
    }
    // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };
    in
    {
      devShells.default = pkgs.mkShell {
        inherit (pre-commit.lib.${system}.run {
          src = builtins.path { path = ./.; };
          hooks = {
            nixpkgs-fmt.enable = true;
            stylua.enable = true;
          };
        }) shellHook;
      };
      formatter = pkgs.nixpkgs-fmt;
      # For use with nvim --embed. This package contains mostly
      # behavioral features of neovim (non-UI features).
      packages.neovim-embed = pkgs.neovim-embed;
      # For standalone usage. This package contains behavioral & UI
      # features.
      packages.neovim = pkgs.neovim;
      packages.default = self.packages.${system}.neovim;
      apps.neovim-embed = flake-utils.lib.mkApp {
        drv = self.packages.${system}.neovim-embed;
        name = "neovim";
        exePath = "/bin/nvim";
      };
      apps.neovim = flake-utils.lib.mkApp {
        drv = self.packages.${system}.neovim;
        name = "neovim";
        exePath = "/bin/nvim";
      };
      apps.default = self.apps.${system}.neovim;
    });
}
