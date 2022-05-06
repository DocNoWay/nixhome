#                                      _
#  _   _ _ __   __ _  ___ ___  _ __ __| | __ _
# | | | | '_ \ / _` |/ __/ _ \| '__/ _` |/ _` |
# | |_| | | | | (_| | (_| (_) | | | (_| | (_| |
#  \__,_|_| |_|\__,_|\___\___/|_|  \__,_|\__,_|
#

{ inputs, lib, pkgs, ... }:

let
  inherit (lib._) enable;
in {
  nix = {
    binaryCaches          = [
      "https://hydra.iohk.io"
      "https://iohk.cachix.org"
    ];
    binaryCachePublicKeys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  imports = [
    ./hardware-configuration.nix
  ];

  #TODO temporary fixes
  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [ font-awesome twitter-color-emoji _.otf-apple _.sf-mono-nerd-font ];
    fontconfig.enable = true;
    fontconfig.defaultFonts = {
      emoji = [ "Font Awesome 5 Free" "Noto Color Emoji" ];
      monospace = [ "SFMono Nerd Font" "SF Mono" ];
      serif = [ "New York Medium" ];
      sansSerif = [ "SF Pro Text" ];
    };
  };
  services.getty.autologinUser = "andreas";

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 524288;
  };
  time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [ efibootmgr ];

  # Various packages that don't fit into any specific module
  user.packages = with pkgs; [
    # Dev

    # Communication

    # Media
    imv transmission-gtk spotify

    # Utils
    ripgrep bat libappindicator pfetch unzip killall ncdu tree pidof

  ];

  modules = {
    shell = {
      git = enable;
      gpg = enable;
      vim = {
        enable = true;
        lsp.servers = [
          "elisp"
          "clojure_lsp"
          "rnix"
          "python"
        ];
      };
      pass = enable;
      ssh = enable;
      bash = enable;
    };
    desktop = {
      gtk.enable = true;
      games.enable = true;
      swaywm = {
        enable = true;
        term = "alacritty";
        wallpaper = ./assets/bg.jpg;
        lockWallpaper = ./assets/lock.jpg;
      };
      services = {
        wlsunset = enable;
      };
      apps = {
        qutebrowser= enable;
        firefox = enable;
        mpd = enable;
        zathura = enable;
      };
    };
    dev = {
      direnv = enable;

      clojure = enable;
      nix = enable;
    };
    hardware = {
      audio = {
        enable = true;
        pulseeffects.enable = false;
      };
      bluetooth = enable;
      graphics = {
        enable = true;
        vaapi.enable = true;
        vaapi.intelHybrid = true;
      };
    };
    services = {
      networkmanager = enable;
    };
  };

  # Various other services that don't live in modules
  services = {
    printing = enable;
    udisks2 = enable;
  };
}
