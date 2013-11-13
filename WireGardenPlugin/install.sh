#!/bin/bash
# Install script for the WireGarden browser plugin
# More information at WireGarden.org

#### Variables

version="1.0.0.6"
installDir="/opt/WireGarden/WireGardenPlugin/$version"
pluginDir="/usr/lib/mozilla/plugins"
bit="32"

#### Functions

function checkCommand(){
    local command_loc=""
    if ! command_loc="$(type -p "$1")" || [ -z "$command_loc" ]; then
        return 1
    fi
    return 0
}

function echoUsage(){
    echo -e "
    Usage: $0 [options] [Install Directory]
        Install the WireGarden browser plugin.
        Install Directory defaults to: /opt/WireGarden

    Options:
        -64\t\tInstall 64 bit Arduino toolchain. Defaults to 32 bit.
        -h, --help\tShow this message and exit.
"
}

function install(){
    # Check for make, cmake, and g++
    if ! checkCommand "make"; then
        echo "Error: Make is required. Please install Make and run this script again."
        exit 1
    fi
    if ! checkCommand "cmake"; then
        echo "Error: CMake is required. Please install CMake and run this script again."
        exit 1
    fi
    if ! checkCommand "g++"; then
        echo "Error: g++ is required. Please install g++ and run this script again."
        exit 1
    fi

    # cd to our own directory
    scriptDir="$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"
    cd $scriptDir

    # Make sure the plugin has been built first
    if [ ! -f "Build/bin/WireGardenPlugin/npWireGardenPlugin.so" ]; then
        echo "Error: The plugin must be built first. Please run build.sh and then run this script again."
        exit 1
    fi

    # Create install directory
    if [ ! -d "$installDir" ]; then
        # Create directory
        echo "Creating installation directory: $installDir."
        if ! mkdir -p "$installDir"; then
            echo "Error: Could not create installation directory. You may need to run this script with sudo."
            exit 1
        fi
    fi

    # Create libraries directory
    echo "Creating libraries directory under installation directory."
    if ! mkdir -p "$installDir/libraries"; then
        echo "Error: Could not create libraries directory under installation directory."
        exit 1
    fi

    # Create hardware directory
    echo "Creating hardware directory under installation directory."
    if ! mkdir -p "$installDir/hardware"; then
        echo "Error: Could not create hardware directory under installation directory."
        exit 1
    fi

    # Copy Arduino Tools
    echo "Copying hardware files to installation directory."
    if ! cp -r "arduinoTools/hardware" "$installDir"; then
        echo "Error: Could not copy Arduino tool files."
        exit 1
    fi

    echo "Copying Arduino tool files to installation directory. - $bit bit"
    if ! cp -r "arduinoTools/$bit/hardware" "$installDir"; then
        echo "Error: Could not copy Arduino tool files."
        exit 1
    fi

    echo "Copying Arduino libraries to installation directory."
    if ! cp -pr "arduinoTools/libraries" "$installDir"; then
        echo "Error: Could not copy Arduino tool files."
        exit 1
    fi

    # Copy domain whitelist
    echo "Copying domain whitelist installation directory"
    if ! cp "Source/WireGardenPlugin/whitelist.txt" "$installDir"; then
        echo "Error: Could not copy plugin."
        exit 1
    fi


    # Copy plugin
    echo "Copying plugin to installation directory"
    if ! cp "Build/bin/WireGardenPlugin/npWireGardenPlugin.so" "$installDir"; then
        echo "Error: Could not copy plugin."
        exit 1
    fi

    # Create plugin directory if it doesn't exist
    if [ ! -d "$pluginDir" ]; then
        # Create directory
        echo "Creating plugin directory: $pluginDir."
        if ! mkdir -p "$pluginDir"; then
            echo "Error: Could not create plugin directory. You may need to run this script with sudo."
            exit 1
        fi
    fi

    # Create plugin symlink
    echo "Creating symlink for plugin in $pluginDir"
    cd "$pluginDir"
    if ! ln -sf "$installDir/npWireGardenPlugin.so" "npWireGardenPlugin.so"; then
        echo "Error: Could not create symlink for plugin."
        exit 1
    fi

    # Set permissions and access control
    echo "Setting permissions for installation directory to 777"
    if ! chmod -R a=rwx $installDir/../../; then
        echo "Error: could not set permissions for installation directory. You may need to run this script with sudo."
        exit 1
    fi

    echo "Setting access control for installation directory. Newly created files and folders will have permissions 777."
    if ! setfacl -d -m u::rwx,g::rwx,o::rwx $installDir; then
        echo "Error: could not set access control for installation directory. You may need to run this script with sudo."
        exit 1
    fi

    return 0
}

#### Main

# Get our arguments
while :
do
    case $1 in
        -h | --help)
            echoUsage
            exit 0
            ;;
        -64)
            bit="64"
            shift
            break
            ;;
        --) # End of all options
            shift
            break
            ;;
        -*)
            echo "Error: Unknown option: $1" >&2
            echoUsage
            exit 1
            ;;
        *)  # no more options. Stop while loop
            break
            ;;
    esac
done

# Check for an install directory
if [ "$#" -eq 1 ]; then
    # Remove the trailing slash
    installDir=`echo "${1}" | sed -e "s/\/*$//" `
    # Add the version on to it
    installDir="$installDir/WireGarden/WireGardenPlugin/$version"
fi

# Start installation
echo "Installing to: $installDir"
install
echo "Installation complete.

*************
* IMPORTANT *
*************
Attach your Arduino and check the group that owns it.
Add your user to that group if you're not already a member.

"
exit 0
