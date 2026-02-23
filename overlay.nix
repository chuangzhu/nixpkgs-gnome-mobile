self: super:

let
  gvc = super.fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "libgnome-volume-control";
    rev = "5f9768a2eac29c1ed56f1fbb449a77a3523683b6";
    hash = "sha256-gdgTnxzH8BeYQAsvv++Yq/8wHi7ISk2LTBfU8hk12NM=";
  };
  libshew = super.fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "libshew";
    rev = "ed782477cb5164320ae4f731d49bc5d475ab2a52";
    hash = "sha256-auv5JsQUkytLLAAJzZlCDw4+v9/JfsCV1hKTa3Ku/Jg=";
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
  gnome-shell =
    (super.gnome-shell.override {
      gnome-settings-daemon = self.gnome-settings-daemon-mobile;
      mutter = self.mutter;
    }).overrideAttrs
      (old: {
        version = "49.mobile.0-unstable-2026-01-30";
        src = super.fetchFromGitLab {
          domain = "gitlab.gnome.org";
          owner = "verdre";
          repo = "gnome-shell-mobile";
          rev = "f9e97c2f43827f22a1a3d7bbda8f8c7e88b450f9"; # mobile-shell-devel-49
          hash = "sha256-XafMWhohuET+1S3At+I+wykqHaL7cM+bYYmTYt74hNs=";
          fetchSubmodules = true;
        };
        prePatch = ''
          cp -r ${libshew} subprojects/libshew
          chmod -R u+w subprojects/libshew
          cp -r ${gvc} subprojects/gvc
          chmod -R u+w subprojects/gvc
        '';
        postPatch = ''
          patchShebangs \
            src/data-to-c.py \
            build-aux/generate-app-list.py

          # We can generate it ourselves.
          rm -f man/gnome-shell.1
        '';
        buildInputs = old.buildInputs ++ [
          super.modemmanager # /org/gnome/shell/misc/modemManager.js
          super.libgudev # /org/gnome/gjs/modules/esm/gi.js
        ];
        postFixup = old.postFixup + ''
          wrapGApp $out/share/gnome-shell/org.gnome.Shell.SensorDaemon
        '';
      });

  gnome-settings-daemon-mobile = super.gnome-settings-daemon.overrideAttrs (old: {
    version = "49.mobile.0-unstable-2026-01-30";
    src = super.fetchFromGitLab {
      domain = "gitlab.gnome.org";
      owner = "verdre";
      repo = "gnome-settings-daemon-mobile";
      rev = "11b4c4a7812a9ad6cca4796b715e6ec8b7c55c3e"; # gnome-49-mobile
      hash = "sha256-Lv79Vx7D7eAVC8alWA8V1aBOmhgXf5mtvZgpPiqx3dk=";
    };
    prePatch = ''
      rm -r subprojects/gvc
      cp -r ${gvc} subprojects/gvc
      chmod -R u+w subprojects/gvc
    '';
  });

  mutter =
    (super.mutter.override { gnome-settings-daemon = self.gnome-settings-daemon-mobile; }).overrideAttrs
      (old: {
        version = "49.mobile.0-unstable-2026-01-30";
        src = super.fetchFromGitLab {
          domain = "gitlab.gnome.org";
          owner = "verdre";
          repo = "mutter-mobile";
          rev = "3d1ac0577cb13baa11e8fe6ee4b192d4b26c7a7a"; # mobile-shell-devel-49
          hash = "sha256-qVwH3/HhxcgyGAbWMYI7t2tJLSNLT9ktJZrwlMonAes=";
        };
        postPatch = old.postPatch + ''
          ln -sf ${gvdb} subprojects/gvdb
        '';
      });
}
