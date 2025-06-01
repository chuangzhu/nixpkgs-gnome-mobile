self: super:

let
  gvc = super.fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "libgnome-volume-control";
    rev = "5f9768a2eac29c1ed56f1fbb449a77a3523683b6";
    hash = "sha256-gdgTnxzH8BeYQAsvv++Yq/8wHi7ISk2LTBfU8hk12NM=";
  };
  gvdb = super.fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "gvdb";
    rev = "b54bc5da25127ef416858a3ad92e57159ff565b3";
    hash = "sha256-c56yOepnKPEYFcU1B1TrDl8ydU0JU+z6R8siAQP4d2A=";
  };
in

{
  gnome-shell = super.gnome-shell.overrideAttrs (old: rec {
    version = "48.mobile.0";
    src = super.fetchFromGitLab {
      domain = "gitlab.gnome.org";
      owner = "verdre";
      repo = "gnome-shell-mobile";
      rev = version;
      hash = "sha256-Iu61qtK0j4OIWpuFjzx8v2G7H7jAbmSBpayuf2h5zUE=";
      fetchSubmodules = true;
    };
    postPatch = ''
      patchShebangs \
        src/data-to-c.py \
        meson/generate-app-list.py

      # We can generate it ourselves.
      rm -f man/gnome-shell.1

      ln -sf ${gvc} subprojects/gvc
    '';
    buildInputs = old.buildInputs ++ [
      super.modemmanager # /org/gnome/shell/misc/modemManager.js
      super.libgudev # /org/gnome/gjs/modules/esm/gi.js
    ];
    postFixup = old.postFixup + ''
      wrapGApp $out/share/gnome-shell/org.gnome.Shell.SensorDaemon
    '';
  });

  gnome-settings-daemon = super.gnome-settings-daemon.overrideAttrs (old: rec {
    version = "48.mobile.0";
    src = super.fetchFromGitLab {
      domain = "gitlab.gnome.org";
      owner = "verdre";
      repo = "gnome-settings-daemon-mobile";
      rev = version;
      hash = "sha256-gLYcjlQ0IcItktRkMEP9k/thYX9sWFzm5P2KF4CS1u8=";
    };
    postPatch = old.postPatch + ''
      rm -r subprojects/gvc
      ln -sf ${gvc} subprojects/gvc
    '';
  });

  mutter = super.mutter.overrideAttrs (old: rec {
    version = "48.mobile.0";
    src = super.fetchFromGitLab {
      domain = "gitlab.gnome.org";
      owner = "verdre";
      repo = "mutter-mobile";
      rev = version;
      hash = "sha256-Qv2a9siPMHJ2dFTpYqDkaHML0jQ89RDpgDu6z6j9Xrc=";
    };
    postPatch = old.postPatch + ''
      ln -sf ${gvdb} subprojects/gvdb
    '';
  });
}

