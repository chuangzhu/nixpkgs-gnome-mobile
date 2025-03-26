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
  gnome-shell = (super.callPackage ./nixpkgs/gn/gnome-shell/package.nix { }).overrideAttrs (old: rec {
    version = "46-mobile.1";
    src = super.fetchFromGitLab {
      domain = "gitlab.gnome.org";
      owner = "verdre";
      repo = "gnome-shell-mobile";
      rev = version;
      hash = "sha256-NL1/mddfaL1rMidsbtV4kG2SlAZZNuR8KmqTmEE4IAM=";
      fetchSubmodules = true;
    };
    postPatch = ''
      patchShebangs src/data-to-c.pl
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

  mutter = ((super.callPackage ./nixpkgs/mu/mutter/package.nix { }).override { mesa = super.libgbm; }).overrideAttrs (old: rec {
    version = "46-mobile.1";
    src = super.fetchFromGitLab {
      domain = "gitlab.gnome.org";
      owner = "verdre";
      repo = "mutter-mobile";
      rev = version;
      hash = "sha256-Xmoq//Igaz1oVt2/aLV+9WjZzW1g6yLADqg97wD3Lug=";
    };
    buildInputs = old.buildInputs ++ [
      super.mesa-gl-headers # EGL/eglmesaext.h: No such file or directory
    ];
  });
}

