{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [ (import ./overlay.nix) ];

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "modesetting" ];
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome = {
    enable = true;
    # One app per workspace
    extraGSettingsOverrides = ''
      [org.gnome.mutter]
      dynamic-workspaces=true
    '';
    extraGSettingsOverridePackages = [ pkgs.gnome.mutter ];
  };

  services.logind.powerKey = "ignore";
  services.logind.powerKeyLongPress = "poweroff";

  # Installed by default but not mobile friendly yet
  environment.gnome.excludePackages = with pkgs.gnome; [
    totem # Videos
    simple-scan # Document Scanner
    gnome-system-monitor
    yelp # Help
    gnome-music
    baobab # Disk Usage Analyser
    evince # Document Viewer
    pkgs.gnome-connections
    pkgs.gnome-tour
  ];

  # Input method works, but these envvars must not be set, or the on-screen keyboard won't pop up.
  # GNOME got a builtin IBus support through IBus' D-Bus API, so these variables are not neccessary.
  environment.variables = {
    GTK_IM_MODULE = lib.mkForce "";
    QT_IM_MODULE = lib.mkForce "";
    XMODIFIERS = lib.mkForce "";
  };
}
