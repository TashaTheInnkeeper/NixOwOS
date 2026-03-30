{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.nixowos-icons = pkgs.callPackage (
        {
          stdenv,
          imagemagick,
          lib,
          runCommand,
          ...
        }:
        stdenv.mkDerivation (finalAttrs: {
          pname = "nixowos-icons";
          version = "0-unstable-2025-08-05";

          # Wrap the assets path in a derivation with a url attribute
          # for compatibility with overlays that expect src.url (e.g. Stylix)
          src = runCommand "nixowos-assets" {
            passthru.url = "https://github.com/yunfachi/NixOwOS/tree/master/assets";
          } ''
            cp -r ${self + /assets} $out
            chmod -R +w $out
          '';

          nativeBuildInputs = [ imagemagick ];

          installPhase = ''
            set -euo pipefail

            sizes="16 24 32 48 64 72 96 128 256 512 1024"
            category="apps"
            theme="hicolor"
            prefix="$out/share/icons/$theme"

            mkdir -p $prefix

            for size in $sizes; do
              dir="$prefix/''${size}x''${size}/$category"
              mkdir -p "$dir"
              convert -background none -resize ''${size}x''${size} "$src/nixowos-snowflake-colours.svg" "$dir/nix-snowflake.png"
              convert -background none -resize ''${size}x''${size} "$src/nixowos-snowflake-white.svg" "$dir/nix-snowflake-white.png"
            done

            # scalable icons
            for variant in colours white; do
              mkdir -p "$prefix/scalable/$category"
              cp "$src/nixowos-snowflake-''${variant}.svg" "$prefix/scalable/$category/nix-snowflake-''${variant}.svg"
            done
          '';

          meta = {
            description = "Icons of the NixOwOS logo, in Freedesktop Icon Directory Layout";
            homepage = "https://github.com/yunfachi/NixOwOS";
            license = lib.licenses.cc-by-40;
            maintainers = with lib.maintainers; [ yunfachi ];
            platforms = lib.platforms.all;
          };
        })
      ) { };
    };
}
