#!/bin/sh
# Builds the app icon, favicon and Sumi mark from the selected transparent artwork.
# sips, iconutil and base64 ship with macOS; no browser is required.
set -e
cd "$(dirname "$0")/.."
SOURCE="docs/brand/tako.png"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# SVG exports embed the same PNG so they remain portable and preserve the exact chosen mark.
ART=$(base64 -i "$SOURCE" | tr -d '\n')
for name in tako-icon mark-tako; do
  printf '<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024"><image width="1024" height="1024" href="data:image/png;base64,%s"/></svg>\n' "$ART" > "docs/brand/$name.svg"
done
# A black template export keeps the eye shapes transparent for single-color use.
printf '<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024"><defs><filter id="template" color-interpolation-filters="sRGB"><feColorMatrix type="matrix" values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  4 0 0 0 -0.3"/><feComposite in2="SourceGraphic" operator="in"/></filter></defs><image width="1024" height="1024" filter="url(#template)" href="data:image/png;base64,%s"/></svg>\n' "$ART" > docs/brand/tako-template.svg

mkdir "$TMP/AppIcon.iconset"
for s in 16 32 128 256 512; do
  sips -z "$s" "$s" "$SOURCE" --out "$TMP/AppIcon.iconset/icon_${s}x${s}.png" >/dev/null
  sips -z $((s * 2)) $((s * 2)) "$SOURCE" --out "$TMP/AppIcon.iconset/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$TMP/AppIcon.iconset" -o Resources/AppIcon.icns
sips -z 256 256 "$SOURCE" --out docs/icon.png >/dev/null
sips -z 192 192 "$SOURCE" --out Resources/Mark/tako.png >/dev/null

echo "Built Resources/AppIcon.icns, docs/icon.png, Resources/Mark/tako.png and portable brand SVGs"
