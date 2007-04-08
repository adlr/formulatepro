#!/bin/bash

# $1 - source folder
# $2 - volume name
# $3 - output file

# for example:
# ./release.sh ./build/Release/FormulatePro.app FormulatePro-0.0.2 FormulatePro-0.0.2.dmg

GZIP=-9 hdiutil create -fs HFS+ -srcfolder $1 -volname $2 $3
