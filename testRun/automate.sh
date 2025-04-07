#!/bin/bash
###########################################################################
##  usage: $0 <data_dir> <job_id> (optional <scripts_dir>)
##
##     automatically extract and plot from <data_dir>/<job_id> using scripts
##     from adiosProfileAnalysis/ (expecting utils/ and scripts/)
##     by default it plots times 0 1 2 3
##     if you need other times, change the iteration variable in this script
##     e.g. to run in this dir, plot for job data/37404600  using the scripts in ../
##        source automate.sh data 37404600 ../
###########################################################################
### process all jsons from data/ (data/<job1> data/<job2> ..)
#source step0.sh data

# Check for required scripts
for script in step1.sh step2.sh; do
    if [ ! -f "$script" ]; then
        echo "Error: Required script $script not found"
        exit 1
    fi
done
### extract json valutes from job id 36832543

runStep1()
{
    local dir="$1"    
    local jobID="$2"

    if [ ! -d "$dir" ]; then
        echo "Error: Directory $dir does not exist"
        return 1
    fi

    for i in "${iterations[@]}"; do
        if ! source ./step1.sh "${scripts_home}/scripts/" "$dir" "$jobID" "$i"; then
            echo "Warning: step1.sh failed for iteration $i"
	    break
        fi
    done
}


runStep2()
{
    local jobID="$1"
    local extractedDir="$2"

    if [ ! -d "$extractedDir/$jobID" ]; then
        echo "Error: Output directory $extractedDir/$jobID does not exist"
        return 1;
    fi
    
    for i in "${iterations[@]}"; do	
        #if ! source ./step2.sh "$jobID" "adiosProfilerAnalysis/scripts" "$extractedDir/$jobID" "$i"; then
	if ! source ./step2.sh "$jobID" "${scripts_home}/scripts/" "$extractedDir/$jobID" "$i"; then
            echo "Warning: step2.sh failed for iteration $i"
        fi
    done
}

if [ "$#" -lt 2 ]; then
    echo "Error: This script requires 2+ arguments"
    echo "Usage: $0 <data_dir> <job_id> <script_home>(adiosProfilerAnalysis/scripts/)" 
    exit 1
fi

# Check if arguments are not empty
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Arguments cannot be empty"
    echo "Usage: $0 <data_dir> <job_id>"
    exit 1
fi

# Validate input
#if [ -z "$1" ]; then
#    echo "Usage: $0 <data_dir> <job_id>"
#    exit 1
#fi

iterations=(0 1 2 3)
job="$2"
data_dir="$1"
scripts_home="adiosProfilerAnalysis/"
if [ "$#" -gt 2 ]; then
    scripts_home="$3"
fi

if [ ! -d "$data_dir"/${job} ]; then
    echo "Invalid datadir ${data_dir}/${job}"
else
    if [ ! -d "${scripts_home}/scripts" ]; then
	echo "Unable to find dir  ${scripts_home}/scripts "
    else
	output_dir="all_outs"

	## optional, check ADIOS json file summary
	#source ${scripts_home}/utils/reportADIOS.sh ${data_dir}	
	echo "Extracting information from: $data_dir/$job scripts from ${scripts_home}/scripts"
	runStep1 "$data_dir" "$job" || { echo "Error: Step 1 failed" ; exit 1 }					
	runStep2 "$job" "$output_dir" || { echo "Error: Step 2 failed" ; exit 1 }
	
    fi
fi	




