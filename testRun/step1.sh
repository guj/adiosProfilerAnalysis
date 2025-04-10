#!/bin/bash
#########################################################################################################  
## goal: extra data from 3 files flatten/default/joined
#########################################################################################################  
## expect dir structure: ${dataDir}/${jobID}/*_${jobID}_${type}_${numNodes}
##                  e.g. data/36820518/f_36820518_flatten_128n
##
## usage:  
##     source <this_file> data 36820518 0
##     "purpose: extract all json attributes from dir=data/ + job id=36820518 + at_step=0"
##########################################################################################################
if [ "$#" -lt 4 ]; then
    echo "Error: 4+ arguments required"
    echo "Usage: $0 <scriptHome> <dataDir> <jobID> <timeStep>"
    exit 1
fi

scriptsHome=$1
dataDir=$2
jobID=$3
timeStep=$4

aggType="ews"

if  [ "$#" -eq 5 ]; then
    aggType=$5

# Validate timeStep is a number
if ! [[ "$timeStep" =~ ^[0-9]+$ ]]; then
    echo "Error: timeStep must be a non-negative integer, got '$timeStep'"
    exit 1
fi

if [ ! -d "$dataDir/$jobID" ]; then
    echo "Error: Directory '$dataDir/$jobID' does not exist"
    exit 1
fi

type1=default
type2=flatten
type3=joined

declare -a path1 path2 path3

#####################
## ls could have multiple outputs, e.g, asyncdefault, default both can be in one job
## so put results in an array 
#####################
path1=($(ls ${dataDir}/${jobID}/*${type1}_*/jsons/*/*${timeStep}.bp*${aggType}*))
path2=($(ls ${dataDir}/${jobID}/*${type2}_*/jsons/*/*${timeStep}.bp*${aggType}*))
path3=($(ls ${dataDir}/${jobID}/*${type3}_*/jsons/*/*${timeStep}.bp*${aggType}*))


# Check if any paths were found
if [ ${#path1[@]} -eq 0 ] && [ ${#path2[@]} -eq 0 ] && [ ${#path3[@]} -eq 0 ]; then
    echo "\nError: No matching files found in '$dataDir/$jobID' for timeStep $timeStep"
else

    #source adiosProfilerAnalysis/scripts/extract.sh all ${path1} ${path2} ${path3}
    source ${scriptsHome}/extract.sh all ${path1} ${path2} ${path3}
    mkdir all_outs
    mkdir all_outs/${jobID}
    destination=all_outs/${jobID}/t${timeStep}
    rm -rf  ${destination}
    mv outs ${destination}
fi
echo "-----  Finished. Check results in: ${destination}   ----"
