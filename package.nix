{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  udev,
  libdrm,
  libpqxx,
  unixODBC,
  libpulseaudio,
  gst_all_1,
  xorg,
}:

let
  release = import ./version.nix;
in
stdenv.mkDerivation {
  pname = "freedownloadmanager";
  inherit (release) version;

  src = fetchurl {
    inherit (release) url hash;
  };

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    chmod -R u+w .
    runHook postUnpack
  '';

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = [
    libdrm
    libpqxx
    unixODBC
    stdenv.cc.cc
    udev
    libpulseaudio
    libxkbcommon
    gtk3
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-libav
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
  ])
  ++ (with xorg; [
    libX11
    libxcb
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
      categories = [
        "Network"
        "FileTransfer"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/freedownloadmanager
    cp -r opt/freedownloadmanager/. $out/opt/freedownloadmanager/

    rm -f $out/opt/freedownloadmanager/plugins/sqldrivers/libqsql{ibase,mimer,mysql,oci}.so
    mkdir -p $out/bin
    ln -s $out/opt/freedownloadmanager/fdm $out/bin/freedownloadmanager

    if [ -f "$out/opt/freedownloadmanager/icon.png" ]; then
      install -Dm644 "$out/opt/freedownloadmanager/icon.png" \
        "$out/share/pixmaps/freedownloadmanager.png"
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "A smart and fast internet download manager";
    homepage = "https://www.freedownloadmanager.org";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "freedownloadmanager";
  };
}
