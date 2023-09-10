self: super: {
  gnome = super.gnome.overrideScope' (gself: gsuper: {
    gnome-shell = gsuper.gnome-shell.overrideAttrs (old: {
      version = "unstable-2023-04-24";
      src = super.fetchFromGitLab {
        domain = "gitlab.gnome.org";
        owner = "verdre";
        repo = "gnome-shell";
        rev = "034144c20f56039901969ae0ff3f9af0e3d79924";
        hash = "sha256-LwFy3Nh4djWjWt7cogsVGk7OlgOPV3gvvRBD7UFTSf8=";
        fetchSubmodules = true;
      };
      patches = builtins.filter (p:
        (builtins.match ".*5766d4111ac065b37417bedcc1b998ab6bee5514.patch" (toString p) == null) &&
        (builtins.match ".*fix-paths.patch" (toString p) == null)) old.patches ++ [ (super.fetchpatch {
          url = "https://github.com/NixOS/nixpkgs/raw/b632011615d783dfb62712e5ba8a2eff35800d28/pkgs/desktops/gnome/core/gnome-shell/fix-paths.patch";
          hash = "sha256-h5fcdXp2HUmlnxnQ6/56FpmvkxNYum+0i10rbN5XhTo=";
        }) ];
      # JS ERROR: Error: Requiring ModemManager, version none: Typelib file for namespace 'ModemManager' (any version) not found
      # @resource:///org/gnome/shell/misc/modemManager.js:4:49
      buildInputs = old.buildInputs ++ [ super.modemmanager ];
      postPatch = ''
        patchShebangs src/data-to-c.pl

        # We can generate it ourselves.
        rm -f man/gnome-shell.1

        # Build fails with -Dgtk_doc=true
        # https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/6486
        # element include: XInclude error : could not load xxx, and no fallback was found
        substituteInPlace docs/reference/shell/shell-docs.sgml \
          --replace '<xi:include href="xml/shell-embedded-window.xml"/>' ' ' \
          --replace '<xi:include href="xml/shell-gtk-embed.xml"/>' ' '
      '';
    });

    mutter = gsuper.mutter.overrideAttrs (old: {
      version = "unstable-2022-12-12";
      src = super.fetchFromGitLab {
        domain = "gitlab.gnome.org";
        owner = "verdre";
        repo = "mutter";
        rev = "780aadd4ed77ca6a8312acb3ab13decdb5b6d569";
        hash = "sha256-0B1HSwnjJHurOYg4iquXZKjbfyGM5xDIDh6FedlBuJI=";
      };
    });
  });
}

