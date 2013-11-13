import os
import distutils.dir_util
import distutils.archive_util

def copySource( inputPath, outputPath ):
    print "copying files to " + outputPath
    files = distutils.dir_util.copy_tree( inputPath, outputPath )
    #for file in files:
        #print file
    print "\tComplete"
    
def createArchive(topLevelDirectory, version):
    name = topLevelDirectory + "_" + version
    print "Creating archive: " + name
    distutils.archive_util.make_archive(name, "gztar", base_dir="WireGardenPlugin")
    print "\tComplete"
    
def getVersion(inputFilename):
    with open(inputFilename) as f:
        version = f.readline()
        return version.strip()

def createInstallScript(versionString):
    with open("install_top.txt") as top, open("install_bottom.txt") as bottom, open("WireGardenPlugin/install.sh","w") as install:
        install.write(top.read())
        install.write('version="%s"\n' % versionString)
        install.write(bottom.read())

# if run as top-level script
if __name__ == '__main__':
    # Copy WireGarden Source into source folder
    copySource("../fbProjects/WireGardenPlugin","WireGardenPlugin/Source/WireGardenPlugin")
    # Version
    versionString = getVersion("version.txt")
    # Create install script with correct version
    createInstallScript(versionString)
    # Create Archive
    createArchive("WireGardenPlugin", versionString)
