{
  spotify,
  rustPlatform,
  fetchFromGitHub,
  zip,
  unzip,
}:
let
  version = "1.1.1";
  spotify-adblock = rustPlatform.buildRustPackage {
    inherit version;
    pname = "spotify-adblock";
    src = fetchFromGitHub {
      owner = "abba23";
      repo = "spotify-adblock";
      rev = "refs/tags/v${version}";
      fetchSubmodules = false;
      hash = "sha256-R1xM/a+EzFd3I94EVCphbW+M114x6CtIeCOi9Fd9tpc=";
    };
    cargoHash = "sha256-gxGetdqaoJa/ZF1VnW6UXJyJfLBGZxZnyKpT/Qk/8Og=";

    patchPhase = ''
      substituteInPlace src/config.rs \
        --replace-fail 'const GLOBAL_CONFIG_DIR: &str = "/etc";' \
                  "const GLOBAL_CONFIG_DIR: &str = \"$out/etc\";"
    '';

    buildPhase = ''
      make
    '';

    installPhase = ''
      mkdir -p $out/etc/spotify-adblock
      install -D --mode=644 config.toml $out/etc/spotify-adblock
      mkdir -p $out/lib
      install -D --mode=644 --strip target/release/libspotifyadblock.so $out/lib
    '';
  };
in
spotify.overrideAttrs (old: {
  buildInputs = (old.buildInputs or [ ]) ++ [
    zip
    unzip
  ];
  postInstall = (old.postInstall or "") + ''
    ln -s ${spotify-adblock}/lib/libspotifyadblock.so $libdir
    sed -i "s:^Name=Spotify.*:Name=Spotify-adblock:" "$out/share/spotify/spotify.desktop"
    wrapProgram $out/bin/spotify \
      --set LD_PRELOAD "${spotify-adblock}/lib/libspotifyadblock.so"

    # Hide placeholder for advert banner
    ${unzip}/bin/unzip -p $out/share/spotify/Apps/xpui.spa xpui-snapshot.js | sed 's/adsEnabled:\!0/adsEnabled:false/' > $out/share/spotify/Apps/xpui-snapshot.js
    ${zip}/bin/zip --junk-paths --update $out/share/spotify/Apps/xpui.spa $out/share/spotify/Apps/xpui-snapshot.js
    rm $out/share/spotify/Apps/xpui-snapshot.js
  '';
})
