# Nyxt 5.1.0 with the CEF renderer — starting point, untested.
# Mirrors flathub/engineer.atlas.Nyxt PR #23 (manifest + flatpak-build.sh).
{
  lib,
  stdenv,
  fetchurl,
  sbcl,
  cmake,
  pkg-config,
  wayland-scanner,
  makeWrapper,
  autoPatchelfHook,
  addDriverRunpath,
  cacert,
  fetchFromGitHub,
  writeText,
  # Lisp foreign libraries (dlopen'd by name at build time and runtime)
  libfixposix,
  enchant,
  openssl,
  sqlite,
  wayland,

  # libcef.so runtime deps (prebuilt Chromium)
  glib,
  nss,
  nspr,
  at-spi2-core,
  libdrm,
  libgbm,
  expat,
  libxkbcommon,
  xorg,
  gtk3,
  pango,
  cairo,
  alsa-lib,
  dbus,
  cups,
  libpulseaudio,
  libGL,
  udev,
  vulkan-loader,
}:

let
  version = "5.1.0";

  # Stand-in for ocicl's runtime (ocicl isn't in nixpkgs): resolve systems
  # from ./ocicl.csv into the vendored ./ocicl/ tree, never download.
  ocicl-runtime-stub = writeText "ocicl-runtime.lisp" ''
    (defpackage #:ocicl-runtime
      (:use #:cl)
      (:export #:*download* #:*verbose*))
    (in-package #:ocicl-runtime)

    (defvar *download* nil)
    (defvar *verbose* nil)
    (defvar *systems* (make-hash-table :test 'equal))

    (defun csv-name->asdf-name (name)
      "ocicl encodes + as _plus_ (cl_plus_ssl -> cl+ssl)."
      (let ((out name) (pos nil))
        (loop while (setf pos (search "_plus_" out))
              do (setf out (concatenate 'string (subseq out 0 pos) "+"
                                        (subseq out (+ pos (length "_plus_"))))))
        out))

    (let* ((root (uiop:getcwd))
           (vendored (merge-pathnames "ocicl/" root))
           (csv (merge-pathnames "ocicl.csv" root)))
      (with-open-file (in csv)
        (loop for line = (read-line in nil)
              while line
              for parts = (uiop:split-string line :separator ",")
              when (= (length parts) 3)
                do (setf (gethash (csv-name->asdf-name (string-trim " " (first parts)))
                                  *systems*)
                         (merge-pathnames (string-trim " " (third parts)) vendored)))))

    (push (lambda (name)
            (let ((path (gethash (asdf:primary-system-name name) *systems*)))
              (when (and path (probe-file path))
                path)))
          asdf:*system-definition-search-functions*)
  '';

  # Libraries libcef.so links against (DT_NEEDED).
  cefLibs = [
    glib
    nss
    nspr
    at-spi2-core
    libdrm
    libgbm
    expat
    pango
    cairo
    alsa-lib
    dbus
    cups
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxshmfence
  ];
  # Prebuilt CEF minimal SDK, the same one Flathub builds against (CEF 150).
  cefSdk = fetchurl {
    url = "https://github.com/atlas-engineer/cef/releases/download/150.0.22%2Bgc1a097e%2Bchromium-150.0.7871.256/cef_binary_150.0.22%2Bgc1a097e%2Bchromium-150.0.7871.256_linux64_minimal.tar.bz2";
    sha256 = "d63964452b43b1272c6a3a2884e1b6626894662b8a10dab76304bd9fe6d1dea8";
  };

  # Every Lisp dependency pinned in ocicl.csv, vendored by upstream.
  ocicl-vendor = fetchurl {
    url = "https://github.com/atlas-engineer/nyxt/releases/download/${version}/nyxt-${version}-ocicl.tar.gz";
    sha256 = "af8ce4e52b6245131bde888ece803824dedfe0e58f45fe39f1bbe4d290ef7bab";
  };

  # Libraries the Lisp image dlopens by soname.
  lispLibs = [
    libfixposix
    enchant
    openssl
    sqlite
    wayland
    xorg.libX11
  ];

  # Extra libraries Chromium dlopens at runtime (not in DT_NEEDED).
  cefDlopenLibs = [
    gtk3
    libGL
    libpulseaudio
    udev
    vulkan-loader
    libxkbcommon
  ];
in
stdenv.mkDerivation {
  pname = "nyxt";
  inherit version;

  # GitHub tag tarball (flat hash computed from the download).
  # If GitHub ever regenerates it, switch to fetchFromGitHub + rev 02d338bdcdcf71bb14f80da32ca5b46d271a5e96.
  src = fetchFromGitHub {
    owner = "atlas-engineer";
    repo = "nyxt";
    rev = "02d338bdcdcf71bb14f80da32ca5b46d271a5e96"; # tag 5.1.0
    hash = "sha256-V7yDhucnR4FyQli9mUCdy8jSKlAmOE2KvEVwX8WHqCY=";
  };

  postUnpack = ''
    tar -xzf ${ocicl-vendor} -C "$sourceRoot"
    mkdir -p "$sourceRoot/cef-sdk"
    tar -xjf ${cefSdk} -C "$sourceRoot/cef-sdk" --strip-components=1
  '';

  nativeBuildInputs = [
    sbcl
    cmake
    pkg-config
    wayland-scanner
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = lispLibs ++ cefDlopenLibs ++ cefLibs;

  # The makefile drives cmake itself on cl-cef; there is no top-level CMakeLists.
  dontUseCmakeConfigure = true;

  # flatpak-build.sh strips _FORTIFY_SOURCE for the CEF wrapper build.
  hardeningDisable = [ "fortify" "fortify3" ];

  # The nyxt binary is an SBCL runtime with the core appended:
  # stripping or patchelf'ing it can corrupt the image.
  dontStrip = true;
  dontPatchELF = true;
  dontAutoPatchelf = true; # run it by hand on lib/cef only, see postFixup

  postPatch = ''
    # Skip `ocicl install` (network); everything is vendored already.
    substituteInPlace makefile \
      --replace-fail 'cd $(makefile_dir) && CL_SOURCE_REGISTRY= $(OCICL) -c never install' 'true'

    # cl-clipboard's makefile clobbers CFLAGS if set; append instead (as Flathub does).
    sed -i 's/^CFLAGS ?=/CFLAGS +=/' ocicl/cl-clipboard-e52a716/makefile

    # cl-cef resolves its helper and resources relative to the ASDF system
    # (i.e. the build dir), which won't exist at runtime. Point it at $out.
    substituteInPlace ocicl/cl-cef-ff7b41f/source/lisp/core.lisp \
      --replace-fail '(asdf:system-relative-pathname :cl-cef "build/cl-cef-helper")' \
                     '#p"'"$out"'/lib/cef/cl-cef-helper"' \
      --replace-fail '(asdf:system-relative-pathname :cl-cef "build/")' \
                     '#p"'"$out"'/lib/cef/"'
  '';

  buildPhase = ''
    runHook preBuild

    export HOME="$TMPDIR"
    export XDG_CACHE_HOME="$TMPDIR/cache"
    export CMAKE_BUILD_PARALLEL_LEVEL="$NIX_BUILD_CORES"
    export LD_LIBRARY_PATH="${lib.makeLibraryPath (lispLibs ++ cefDlopenLibs ++ cefLibs)}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

    # Build the clipboard shim up front so it isn't built mid-load.
    make -C ocicl/cl-clipboard-e52a716

    make \
      NYXT_RENDERER=cef \
      CEF_ROOT="$PWD/cef-sdk" \
      OCICL_RUNTIME=${ocicl-runtime-stub} \
      nyxt

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cef_build=ocicl/cl-cef-ff7b41f/build
    clipboard_dir=ocicl/cl-clipboard-e52a716

    install -Dm755 nyxt "$out/bin/nyxt"
    install -Dm755 "$clipboard_dir/libcl-clipboard.so" "$out/lib/libcl-clipboard.so"

    mkdir -p "$out/lib/cef"
    for f in \
      libcl-cef.so cl-cef-helper chrome-sandbox libcef.so \
      libEGL.so libGLESv2.so libvk_swiftshader.so libvulkan.so.1 \
      v8_context_snapshot.bin vk_swiftshader_icd.json \
      chrome_100_percent.pak chrome_200_percent.pak resources.pak icudtl.dat
    do
      cp -f "$cef_build/$f" "$out/lib/cef/$f"
    done
    cp -a "$cef_build/locales" "$out/lib/cef/locales"
    chmod 755 "$out/lib/cef/"{cl-cef-helper,chrome-sandbox,libcl-cef.so,libcef.so}
    patchelf --set-rpath '$ORIGIN' "$out/lib/cef/libcl-cef.so" "$out/lib/cef/cl-cef-helper"
    install -Dm644 assets/nyxt.desktop "$out/share/applications/nyxt.desktop"
    install -Dm644 assets/nyxt.metainfo.xml "$out/share/metainfo/nyxt.metainfo.xml"
    for size in 16 32 128 256 512; do
      install -Dm644 "assets/icons/nyxt_''${size}x''${size}.png" \
        "$out/share/icons/hicolor/''${size}x''${size}/apps/nyxt.png"
    done

    runHook postInstall
  '';

  postFixup = ''
    autoPatchelf "$out/lib/cef" "$out/lib/libcl-clipboard.so"

    wrapProgram "$out/bin/nyxt" \
      --set CL_CEF_LIBRARY "$out/lib/cef/libcl-cef.so" \
      --set CL_CLIPBOARD_LIBRARY "$out/lib/libcl-clipboard.so" \
      --set-default SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt" \
            --prefix LD_LIBRARY_PATH : "$out/lib/cef:$out/lib:${lib.makeLibraryPath (lispLibs ++ cefDlopenLibs ++ cefLibs)}:${addDriverRunpath.driverLink}/lib"
  '';

  meta = {
    description = "Keyboard-oriented, infinitely extensible web browser (CEF renderer)";
    homepage = "https://nyxt-browser.com/";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    mainProgram = "nyxt";
  };
}
