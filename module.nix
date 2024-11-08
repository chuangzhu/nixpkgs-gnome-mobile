{ pkgs, ... }:

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
    extraGSettingsOverridePackages = [ pkgs.mutter ];
  };

  services.logind.powerKey = "ignore";
  services.logind.powerKeyLongPress = "poweroff";

  # Installed by default but not mobile friendly yet
  environment.gnome.excludePackages = with pkgs; [
    totem # Videos
    simple-scan # Document Scanner
    gnome-system-monitor
    yelp # Help
    gnome-music
    baobab # Disk Usage Analyser
    evince # Document Viewer
    gnome-connections
    gnome-tour
  ];

  # Input method works, but these envvars must not be set, or the on-screen keyboard won't pop up.
  # GNOME has a builtin IBus support through IBus' D-Bus API, so these variables are not neccessary.
  environment.extraInit = ''
    unset GTK_IM_MODULE QT_IM_MODULE XMODIFIERS
  '';
}
