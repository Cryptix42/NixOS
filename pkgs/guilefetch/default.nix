{ lib
, stdenvNoCC
, makeWrapper
, guile
, coreutils
, pciutils
, nix
  # Path to a Scheme config baked into the wrapper as GUILEFETCH_CONFIG.
  # The NixOS module passes a generated file here; null leaves the program
  # looking at $XDG_CONFIG_HOME/guilefetch/config.scm.
, defaultConfig ? null
}:

let
  guileVersion = lib.versions.majorMinor guile.version;
  siteDir = "share/guile/site/${guileVersion}";
  ccacheDir = "lib/guile/${guileVersion}/site-ccache";

  # Runtime programs the entries shell out to.  Add to this list when you
  # add an entry that calls something new.
  runtimePath = lib.makeBinPath [ coreutils pciutils nix ];
in
stdenvNoCC.mkDerivation {
  pname = "guilefetch";
  version = "0.1.0";

  src = ./.;
  strictDeps = true;
  nativeBuildInputs = [ makeWrapper guile ];

  # Byte-compile ahead of time so the program never writes to ~/.cache and
  # never pays the compile cost at startup.
  buildPhase = ''
    runHook preBuild
    guild compile --output=guilefetch.go guilefetch.scm
    runHook postBuild
  '';

installPhase = ''
    runHook preInstall

    install -Dm644 guilefetch.scm $out/${siteDir}/guilefetch.scm
    install -Dm644 guilefetch.go  $out/${ccacheDir}/guilefetch.go
    install -Dm644 main.scm       $out/share/guilefetch/main.scm

    makeWrapper ${guile}/bin/guile $out/bin/guilefetch \
      --prefix GUILE_LOAD_PATH : $out/${siteDir} \
      --prefix GUILE_LOAD_COMPILED_PATH : $out/${ccacheDir} \
      --prefix PATH : ${runtimePath} \
      --set GUILE_AUTO_COMPILE 0 \
      ${lib.optionalString (defaultConfig != null)
        "--set-default GUILEFETCH_CONFIG ${defaultConfig}"} \
      --add-flags "-s" \
      --add-flags "$out/share/guilefetch/main.scm"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Extensible system information printer written in Guile Scheme";
    mainProgram = "guilefetch";
    platforms = platforms.linux;
    license = licenses.gpl3Plus;
  };
}
