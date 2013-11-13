#!/bin/bash
# Build script for the WireGarden browser plugin
# More information at WireGarden.org

#### Functions

function checkCommand(){
    local command_loc=""
    if ! command_loc="$(type -p "$1")" || [ -z "$command_loc" ]; then
        return 1
    fi
    return 0
}

#### Main

echo "Building WireGarden browser plugin."

# Check for make and cmake
if ! checkCommand "cmake"; then
    echo "Error: CMake is required. Please install CMake and run this script again."
    exit 1
fi

if ! checkCommand "make"; then
    echo "Error: Make is required. Please install Make and run this script again."
    exit 1
fi

# cd to our own directory
scriptDir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
cd "$scriptDir"

# Due to a bug in the FireBreath build script, we can't have spaces in the path to it.
# Sorting this out currently.
if echo $PWD | grep ' ' >/dev/null; then
    # Space in path
    echo "Due to a limitation of the build system, the path to the WireGardenPlugin directory may not contain spaces. Please move the WireGardenPlugin directory and try again."
    exit 1
fi

# Remove Build directory if it exists
if [ -d "Build" ]; then
    if ! rm -r "Build"; then
        echo "Could not remove Build directory. Please remove $PWD/Build and try again."
        exit 1
    fi
fi

# Generate WireGarden project
echo "Generating plugin files."
#if ! firebreath-1.7/prepmake.sh Source Build -DCMAKE_BUILD_TYPE="Debug"; then
if ! firebreath-1.7/prepmake.sh Source Build; then
    echo "Error: Could not generate plugin files."
    exit 1
fi

# Build WireGarden project
echo "Building plugin."
cd Build/projects/WireGardenPlugin
if ! make; then
    echo "Error: Could not build plugin."
    exit 1
fi

exit 0
