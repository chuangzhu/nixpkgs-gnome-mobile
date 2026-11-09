final: prev:

let
  inherit (prev) lib;

  gvc = prev.fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "libgnome-volume-control";
    rev = "0a4eda0cdc2deb352bebc70ec697c42af46094e4";
    hash = "sha256-4s9S6m/rcroR38FSnLeWKZhnym4KROfibgRCjpGMKpY=";
  };
  libshew = prev.fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "libshew";
    rev = "d16afc40412b565d2bbecf80335f54a19a978009";
    hash = "sha256-qjBnIoCX+mXWDHQ7XBP7PCAoK2loMrLdhdkmZGfPnCA=";
  };
  gvdb = prev.fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "gvdb";
    rev = "b54bc5da25127ef416858a3ad92e57159ff565b3";
    hash = "sha256-c56yOepnKPEYFcU1B1TrDl8ydU0JU+z6R8siAQP4d2A=";
  };
in

{
  gnome-shell =
    (prev.gnome-shell.override {
      gnome-settings-daemon = final.gnome-settings-daemon-mobile;
      mutter = final.mutter;
    }).overrideAttrs
      (old: rec {
        version = "51.1.mobile.22";
        src = prev.fetchFromGitLab {
          domain = "gitlab.gnome.org";
          group = "World";
          owner = "MobileShell";
          repo = "gnome-shell-mobile";
          tag = version;
          hash = "sha256-Yak6Te73JS1dgm0CNGldp55bk3RBytCfIR+eOcMlnyc=";
          fetchSubmodules = true;
        };
        prePatch = ''
          cp -r ${libshew} subprojects/libshew
          chmod -R u+w subprojects/libshew
          cp -r ${gvc} subprojects/gvc
          chmod -R u+w subprojects/gvc
        '';

        # Extensions are no longer extracted with unzip in 51.1
        patches = builtins.filter (
          p: !(lib.hasSuffix "fix-paths.patch" (p.name or (baseNameOf p)))
        ) old.patches;
        postPatch =
          lib.concatStringsSep "\n" (
            builtins.filter (l: l != "rm data/theme/gnome-shell-{light,dark}.css") (
              lib.splitString "\n" old.postPatch
            )
          )
          + ''
            substituteInPlace data/org.gnome.Shell-disable-extensions.service \
              --replace-fail "ExecStart=gsettings" "ExecStart=${prev.glib.bin}/bin/gsettings"
            substituteInPlace js/ui/extensionDownloader.js \
              --replace-fail "'glib-compile-schemas'" "'${prev.glib.dev}/bin/glib-compile-schemas'"
            substituteInPlace subprojects/extensions-tool/src/command-install.c \
              --replace-fail '"glib-compile-schemas"' '"${prev.glib.dev}/bin/glib-compile-schemas"'
          '';

        buildInputs = old.buildInputs ++ [
          prev.modemmanager # /org/gnome/shell/misc/modemManager.js
          prev.libgudev # /org/gnome/gjs/modules/esm/gi.js
        ];
        postFixup = old.postFixup + ''
          wrapGApp $out/share/gnome-shell/org.gnome.Shell.SensorDaemon
        '';
      });

  gnome-settings-daemon-mobile = prev.gnome-settings-daemon.overrideAttrs (old: rec {
    version = "51.1.mobile.22";
    src = prev.fetchFromGitLab {
      domain = "gitlab.gnome.org";
      group = "World";
      owner = "MobileShell";
      repo = "gnome-settings-daemon-mobile";
      tag = version;
      hash = "sha256-wej8OmtLGg9etppGZjSUbCEsyxBFcGuc3SHblll3FCY=";
    };
    prePatch = ''
      rm -r subprojects/gvc
      cp -r ${gvc} subprojects/gvc
      chmod -R u+w subprojects/gvc
    '';
  });

  mutter =
    (prev.mutter.override { gnome-settings-daemon = final.gnome-settings-daemon-mobile; }).overrideAttrs
      (old: rec {
        version = "51.1.mobile.22";
        src = prev.fetchFromGitLab {
          domain = "gitlab.gnome.org";
          group = "World";
          owner = "MobileShell";
          repo = "mutter-mobile";
          tag = version;
          hash = "sha256-fcJLrOPHsNBxzk1Ur7uNOfP59hAzW+cWa4o9krlysYQ=";
        };
        postPatch = old.postPatch + ''
          ln -sf ${gvdb} subprojects/gvdb
        '';
      });
}
