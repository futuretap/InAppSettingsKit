#!/bin/bash

# copied & adjusted from https://github.com/abbeycode/UnzipKit/blob/master/Scripts/carthage-validate.sh

if [ -z ${TRAVIS+x} ]; then
    IASKSETTINGSKIT_DIR=`pwd`
    IASKSETTINGSKIT_BRANCH=`git rev-parse --abbrev-ref HEAD` #Current Git branch
else
    IASKSETTINGSKIT_DIR="$TRAVIS_BUILD_DIR"
    IASKSETTINGSKIT_BRANCH="$TRAVIS_BRANCH"
fi


if [ ! -d "$IASKSETTINGSKIT_DIR/InAppSettingsKit.xcodeproj" ]; then
    echo "Make sure to run this from the repo root"
    exit 1
fi

brew install carthage

rm -r CarthageTest
mkdir CarthageTest

echo "git \"$IASKSETTINGSKIT_DIR\" \"$IASKSETTINGSKIT_BRANCH\"" > CarthageTest/Cartfile

pushd CarthageTest > /dev/null

carthage bootstrap --use-xcframeworks --configuration Debug --verbose
EXIT_CODE=$?

echo "Checking for build products..."

if [ ! -d "Carthage/Build/InAppSettingsKit.xcframework" ]; then
    echo "No iOS library built"
    EXIT_CODE=1
else
    echo "Found iOS framework"
fi

popd > /dev/null

exit $EXIT_CODE