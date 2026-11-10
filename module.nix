{ pkgs, lib, ... }:

{
  nixpkgs.overlays = [ (import ./overlay.nix) ];

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "modesetting" ];
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome = {
    enable = true;
    # One app per workspace
    extraGSettingsOverrides = ''
      [org.gnome.mutter]
      dynamic-workspaces=true
    '';
    extraGSettingsOverridePackages = [ pkgs.mutter ];
  };

  services.logind.settings.Login = {
    HandlePowerKey = lib.mkDefault "ignore";
    HandlePowerKeyLongPress = lib.mkDefault "poweroff";
  };

  # Installed by default but not mobile friendly yet
  environment.gnome.excludePackages = with pkgs; [
    gnome-system-monitor
    yelp # Help
    baobab # Disk Usage Analyser
    evince # Document Viewer
    gnome-tour
  ];

  # Input method works, but these envvars must not be set, or the on-screen keyboard won't pop up.
  # GNOME has a builtin IBus support through IBus' D-Bus API, so these variables are not neccessary.
  environment.extraInit = ''
    unset GTK_IM_MODULE QT_IM_MODULE XMODIFIERS
  '';
}
