{
  outputs = { self, ... }: {
    overlays.default = import ./overlay.nix;
    nixosModules.gnome-mobile = import ./module.nix;
  };
}
