# Neovim

This repo provides a nix flake for my personalized neovim. The flake provides a
package, app, and overlay.

WARNING: This flake pulls in various language servers, so the final derivation
is quite large.

## TODO

Provide derivations for different languages so that the final derivation size
can be much smaller if there is only the need for single language support.
