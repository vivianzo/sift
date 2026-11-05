#!/usr/bin/env bash
# Sets up a "Sift Dev iPhone" simulator with sample photos, so you can test with a realistic
# library without touching your normal simulator. Running it again erases and reseeds the
# dev simulator, so the library is always the same.
#
# Usage: scripts/seed-simulator.sh [--bulk N]
#   --bulk N   also add N filler photos, for scroll testing (e.g. --bulk 1200)

set -euo pipefail

NAME="Sift Dev iPhone"
DEVICE_TYPE="iPhone 17"
BULK=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bulk) BULK="$2"; shift 2 ;;
    -h | --help) sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $1 (try --help)" >&2; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Newest installed iOS runtime.
RUNTIME=$(xcrun simctl list runtimes -j | python3 -c '
import json, sys
runtimes = [r for r in json.load(sys.stdin)["runtimes"] if r["platform"] == "iOS" and r["isAvailable"]]
print(max(runtimes, key=lambda r: [int(p) for p in r["version"].split(".")])["identifier"])')

UDID=$(xcrun simctl list devices -j | python3 -c '
import json, sys
name = sys.argv[1]
for devices in json.load(sys.stdin)["devices"].values():
    for d in devices:
        if d["name"] == name and d["isAvailable"]:
            print(d["udid"]); sys.exit()' "$NAME")

if [[ -n "$UDID" ]]; then
  echo "Erasing existing \"$NAME\"..."
  xcrun simctl shutdown "$UDID" 2>/dev/null || true
  xcrun simctl erase "$UDID"
else
  echo "Creating \"$NAME\" ($DEVICE_TYPE, ${RUNTIME##*.})..."
  UDID=$(xcrun simctl create "$NAME" "$DEVICE_TYPE" "$RUNTIME")
fi

echo "Booting..."
xcrun simctl boot "$UDID"
xcrun simctl bootstatus "$UDID" -b > /dev/null

PHOTOS=$(mktemp -d)
trap 'rm -rf "$PHOTOS"' EXIT
swift "$SCRIPT_DIR/SeedPhotos.swift" "$PHOTOS" "$BULK"

echo "Importing into Photos..."
find "$PHOTOS" -name '*.jpg' -print0 | sort -z | xargs -0 -n 200 xcrun simctl addmedia "$UDID"

open -a Simulator --args -CurrentDeviceUDID "$UDID"
echo "Done. In Xcode, pick \"$NAME\" as the run destination. The app asks for photo access on first launch."
