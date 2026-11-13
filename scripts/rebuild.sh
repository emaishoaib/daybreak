#!/bin/bash
#
# Builds Daybreak in Release for the Mac. The app is quit and installed into /Applications,
# replacing the copy there, then reopened from there. If the build fails, nothing running is
# touched.

set -euo pipefail

cd "$(dirname "$0")/.."

PROJECT=Daybreak.xcodeproj
DERIVED_DATA=build
MAC_APP=$DERIVED_DATA/Build/Products/Release/Daybreak.app
INSTALLED_APP=/Applications/Daybreak.app
MAC_PROCESS=Daybreak.app/Contents/MacOS/Daybreak
LOG=$DERIVED_DATA/rebuild-macOS.log

fail() {
    echo "error: $1" >&2
    exit 1
}

mkdir -p "$DERIVED_DATA"

xcodegen generate

echo "Building the Mac app"
xcodebuild build \
    -project "$PROJECT" \
    -scheme Daybreak-macOS \
    -configuration Release \
    -destination "generic/platform=macOS" \
    -derivedDataPath "$DERIVED_DATA" \
    > "$LOG" 2>&1 \
    || fail "Building Daybreak-macOS failed. See $LOG"

echo "Installing the Mac app in /Applications and reopening it"
pkill -f "$MAC_PROCESS" || true
while pgrep -f "$MAC_PROCESS" > /dev/null; do sleep 0.1; done
rm -rf "$INSTALLED_APP"
ditto "$MAC_APP" "$INSTALLED_APP"
open "$INSTALLED_APP"
