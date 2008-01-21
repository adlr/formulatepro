#!/bin/bash

# $1 - source folder
# $2 - volume name
# $3 - output file

# for example:
# ./release.sh ./build/Release/FormulatePro.app FormulatePro-0.0.2 FormulatePro-0.0.2.dmg

if [ "$1" = "-v" ]; then
	SRC="./build/Release/FormulatePro.app"
	VOL="FormulatePro-$2"
	OUT="$VOL.dmg"
else
	SRC="$1"
	VOL="$2"
	OUT="$3"
fi

echo "SRC = '$SRC'"
echo "VOL = '$VOL'"
echo "OUT = '$OUT'"
GZIP=-9 hdiutil create -fs HFS+ -srcfolder "$SRC" -volname "$VOL" "$OUT"
