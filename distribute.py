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
    
    
# if run as top-level script
if __name__ == '__main__':
    # Copy WireGarden Source into source folder
    copySource("../fbProjects/WireGardenPlugin","WireGardenPlugin/Source/WireGardenPlugin")
    # Create Archive
    createArchive("WireGardenPlugin", "1.0.0.6")
