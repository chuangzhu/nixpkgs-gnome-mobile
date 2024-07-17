self: super:

let
  gvc = super.fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "libgnome-volume-control";
    rev = "5f9768a2eac29c1ed56f1fbb449a77a3523683b6";
    hash = "sha256-gdgTnxzH8BeYQAsvv++Yq/8wHi7ISk2LTBfU8hk12NM=";
  };
in

{
  gnome = super.gnome.overrideScope (gself: gsuper: {
    gnome-shell = gsuper.gnome-shell.overrideAttrs (old: rec {
      version = "46-mobile-0";  # 361fc605e595b36df68d8b691f22bccddcf84cc9
      src = super.fetchFromGitLab {
        domain = "gitlab.gnome.org";
        owner = "verdre";
        repo = "mobile-shell";
        rev = version;
        hash = "sha256-iHDX//QsfDDSv9OnN1E4ZgxVOqzqzNHQC2/ZrAeYUL8=";
        fetchSubmodules = true;
      };
      # JS ERROR: Error: Requiring ModemManager, version none: Typelib file for namespace 'ModemManager' (any version) not found
      # @resource:///org/gnome/shell/misc/modemManager.js:4:49
      buildInputs = old.buildInputs ++ [ super.modemmanager ];
      postPatch = ''
        patchShebangs src/data-to-c.pl
        ln -sf ${gvc} subprojects/gvc
      '';
    });

    mutter = gsuper.mutter.overrideAttrs (old: rec {
      version = "46-mobile-0";  # 805bce1ffa98a4aad180988c7aa7c34115da1d5d
      src = super.fetchFromGitLab {
        domain = "gitlab.gnome.org";
        owner = "verdre";
        repo = "mobile-mutter";
        rev = version;
        hash = "sha256-l2iKUvzW0FPPccQkhd2bDdd+BD4ZHi21MOHLhZCJwbY=";
      };
    });
  });
}

