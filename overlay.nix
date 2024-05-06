self: super: {
  gnome = super.gnome.overrideScope (gself: gsuper: {
    gnome-shell = (gself.callPackage ./gnome-shell { }).overrideAttrs (old: {
      version = "unstable-2024-04-27";
      src = super.fetchFromGitLab {
        domain = "gitlab.gnome.org";
        owner = "verdre";
        repo = "mobile-shell";
        rev = "3a352e95bf540d663f35554ee2de5dcd1ff408bc";
        hash = "sha256-2FErBxN/WXnl7czNBM8OwVO2fIyu15vwgP6DGhLRBM4=";
        fetchSubmodules = true;
      };
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

    mutter = (gself.callPackage ./mutter { }).overrideAttrs (old: {
      version = "unstable-2023-09-08";
      src = super.fetchFromGitLab {
        domain = "gitlab.gnome.org";
        owner = "verdre";
        repo = "mobile-mutter";
        rev = "0f08f5aba4c9b5ac34b2d5711182d50b719d838e";
        hash = "sha256-du56QMOlM7grN60eafoGTw2JGND6PK1gLrfWufihPO4=";
      };
    });
  });
}

