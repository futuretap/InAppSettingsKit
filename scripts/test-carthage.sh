#!/bin/bash

IASKSETTINGSKIT_DIR=`pwd`
IASKSETTINGSKIT_BRANCH="master"

if [ ! -d "$IASKSETTINGSKIT_DIR/InAppSettingsKit.xcodeproj" ]; then
    echo "Make sure to run this from the repo root"
    exit 1
fi

brew install carthage

rm -r CarthageTest
mkdir CarthageTest

echo "git \"$IASKSETTINGSKIT_DIR\" \"$IASKSETTINGSKIT_BRANCH\"" > CarthageTest/Cartfile

pushd CarthageTest > /dev/null

carthage bootstrap --configuration Debug --verbose
EXIT_CODE=$?

echo "Checking for build products..."

if [ ! -d "Carthage/Build/iOS/InAppSettingsKit.framework" ]; then
    echo "No iOS library built"
    EXIT_CODE=1
else
    echo "Found iOS framework"
fi

popd > /dev/null

exit $EXIT_CODE