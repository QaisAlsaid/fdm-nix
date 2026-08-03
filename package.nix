{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook,
  udev,
  libdrm,
  libpqxx,
  unixODBC,
  gst_all_1,
  xorg,
  libpulseaudio,
  mysql,
  makeDesktopItem,
  copyDesktopItems,
}:

let
  release = import ./version.nix;
in
stdenv.mkDerivation {
  pname = "freedownloadmanager";
  
  inherit (release) version;

  src = fetchurl {
    url = "https://files2.freedownloadmanager.org/6/latest/freedownloadmanager.deb";
    inherit (release) hash;
  };

  unpackPhase = "dpkg-deb -x $src .";

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook
    copyDesktopItems
  ];

  buildInputs = [
    libdrm
    libpqxx
    unixODBC
    stdenv.cc.cc
    mysql80
    udev
    libpulseaudio
  ] ++ (with gst_all_1; [
    gstreamer
    gst-libav
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
  ]) ++ (with xorg; [
    xcbutilwm
    xcbutilimage
    xcbutilkeysyms
    xcbutilrenderutil
  ]);

  desktopItems = [
    (makeDesktopItem {
      name = "freedownloadmanager";
      exec = "freedownloadmanager";
      icon = "freedownloadmanager";
      desktopName = "Free Download Manager";
      categories = [ "Network" "FileTransfer" ];
    })
  ];

  installPhase = ''
    mkdir -p $out/opt/freedownloadmanager
    cp -r opt/freedownloadmanager/* $out/opt/freedownloadmanager/

    mkdir -p $out/bin
    ln -s $out/opt/freedownloadmanager/fdm $out/bin/freedownloadmanager

    mkdir -p $out/share/pixmaps
    if [ -f "$out/opt/freedownloadmanager/icon.png" ]; then
      cp "$out/opt/freedownloadmanager/icon.png" $out/share/pixmaps/freedownloadmanager.png
    fi
  '';

  meta = with lib; {
    description = "A smart and fast internet download manager";
    homepage = "https://www.freedownloadmanager.org";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "freedownloadmanager";
  };
}
