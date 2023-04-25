self: super:
{
  gnome = super.gnome.overrideScope' (gself: gsuper: {
    gnome-shell = gsuper.gnome-shell.overrideAttrs (old: {
      version = "unstable-2023-04-03";
      src = super.fetchFromGitLab {
        domain = "gitlab.gnome.org";
        owner = "verdre";
        repo = "gnome-shell";
        rev = "7244a2d0ba30ff4927da14f2611db0dc777c668b";
        hash = "sha256-4N2L/YsmjsgTGS990HnuFRKxiJKkF0duikT0nbN1w7E=";
        fetchSubmodules = true;
      };
      patches = super.lib.take (builtins.length old.patches - 1) old.patches;
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
