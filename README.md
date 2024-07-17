# nixpkgs-gnome-mobile

<img align="right" width="270" src="https://user-images.githubusercontent.com/31200881/234408804-bb1c50f8-2bb9-4f84-84e4-38e503c79f6e.png">

A Nixpkgs overlay providing patches, and a NixOS module providing useful configurations, for running GNOME Shell on mobile.

* Official blog post about GNOME Shell on mobile: https://blogs.gnome.org/shell-dev/2022/09/09/gnome-shell-on-mobile-an-update/
* Packaging request in Nixpkgs: https://github.com/NixOS/nixpkgs/issues/191711
* A similar work: https://github.com/NixOS/mobile-nixos/pull/576

## Usage

For using with Nixpkgs, add `./overlay.nix` or `nixpkgs-gnome-mobile.overlays.default` to your Nixpkgs overlays. For using with NixOS, add `./module.nix` to your `imports` in `configuration.nix`, or `nixpkgs-gnome-mobile.nixosModules.gnome-mobile` to your `modules` in `nixpkgs.lib.nixosSystem`.

This overlay targets the `nixos-unstable` channel. Please let me know if anything breaks on the latest `nixos-unstable`.

## FAQ

### Do input methods work?

Yes, only IBus works. You have to be careful not to set the `*_IM_MODULE` env vars (done in `./module.nix`), or the keyboard won't pop up. Example NixOS configuration:

```nix
i18n.inputMethod.enable = true;
i18n.inputMethod.type = "ibus";
i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [ libpinyin anthy ];
```

Add input methods in Settings > Keyboard, or with the following command:

```shellsession
$ dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('ibus', 'libpinyin'), ('ibus', 'anthy')]"
```

For the Japanese IME anthy, you may also want to change the input mode from Latin to Kana:

```shellsession
$ dconf write /org/freedesktop/ibus/engine/anthy/common/input-mode 0 # Hiragana
```

### Debugging gnome-shell

The Wayland compositor can be started directly from the Linux console. The log is actually verbose enough to identify problems, but for unknown reasons you may have to redirect the stderr to see it:

```shellsession
$ gnome-shell --wayland 2> gnome-shell.log
```
