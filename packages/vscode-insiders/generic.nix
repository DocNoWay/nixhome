{ stdenv, lib, makeDesktopItem
, unzip, libsecret, libXScrnSaver, wrapGAppsHook
, gtk2, atomEnv, at-spi2-atk, autoPatchelfHook
, systemd, fontconfig, xorg

# Attributes inherit from specific versions
, version, src, meta, sourceRoot
, executableName, longName, shortName, pname
}:

let
  inherit (stdenv.hostPlatform) system;
  waylandOpts = "--enable-features=UseOzonePlatform --ozone-platform=wayland";
in
  stdenv.mkDerivation {

    inherit pname version src sourceRoot;

    passthru = {
      inherit executableName;
    };

    desktopItem = makeDesktopItem {
      name = executableName;
      desktopName = longName;
      comment = "Code Editing. Redefined.";
      genericName = "Text Editor";
      exec = "${executableName} ${waylandOpts} %U";
      icon = "code";
      startupNotify = "true";
      categories = "Utility;TextEditor;Development;IDE;";
      mimeType = "text/plain;inode/directory;";
      extraEntries = ''
        StartupWMClass=${shortName}
        Actions=new-empty-window;
        Keywords=vscode;

        [Desktop Action new-empty-window]
        Name=New Empty Window
        Exec=${executableName} ${waylandOpts} --new-window %F
        Icon=code
      '';
    };

    urlHandlerDesktopItem = makeDesktopItem {
      name = executableName + "-url-handler";
      desktopName = longName + " - URL Handler";
      comment = "Code Editing. Redefined.";
      genericName = "Text Editor";
      exec = "${executableName} ${waylandOpts} --open-url %U";
      icon = "code";
      startupNotify = "true";
      categories = "Utility;TextEditor;Development;IDE;";
      mimeType = "x-scheme-handler/vscode;";
      extraEntries = ''
        NoDisplay=true
        Keywords=vscode;
      '';
    };

    buildInputs = (if stdenv.isDarwin
      then [ unzip ]
      else [ gtk2 at-spi2-atk wrapGAppsHook ] ++ atomEnv.packages)
        ++ [ libsecret libXScrnSaver ]
        ++ [ xorg.libxshmfence ];

    runtimeDependencies = lib.optional (stdenv.isLinux) [ (lib.getLib systemd) fontconfig.lib ];

    nativeBuildInputs = lib.optional (!stdenv.isDarwin) autoPatchelfHook;

    dontBuild = true;
    dontConfigure = true;

    installPhase =
      if system == "x86_64-darwin" then ''
        mkdir -p "$out/Applications/${longName}.app" $out/bin
        cp -r ./* "$out/Applications/${longName}.app"
        ln -s "$out/Applications/${longName}.app/Contents/Resources/app/bin/code" $out/bin/${executableName}
      '' else ''
        mkdir -p $out/lib/vscode $out/bin
        cp -r ./* $out/lib/vscode

        ln -s $out/lib/vscode/bin/${executableName} $out/bin

        mkdir -p $out/share/applications
        ln -s $desktopItem/share/applications/${executableName}.desktop $out/share/applications/${executableName}.desktop
        ln -s $urlHandlerDesktopItem/share/applications/${executableName}-url-handler.desktop $out/share/applications/${executableName}-url-handler.desktop

        mkdir -p $out/share/pixmaps
        cp $out/lib/vscode/resources/app/resources/linux/code.png $out/share/pixmaps/code.png

        # Override the previously determined VSCODE_PATH with the one we know to be correct
        sed -i "/ELECTRON=/iVSCODE_PATH='$out/lib/vscode'" $out/bin/${executableName}
        grep -q "VSCODE_PATH='$out/lib/vscode'" $out/bin/${executableName} # check if sed succeeded
      '';

    inherit meta;
  }

