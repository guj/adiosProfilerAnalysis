#!/bin/bash
################################################################
# Generate plots comparing default, flatten, and joined data types
# Usage: ./script.sh <jobID> <scriptsHome> <extractedFilesBase> <timeStep>
# Example: ./script.sh 12345 /path/to/scripts /path/to/extracted 0
################################################################

# Validate input parameters
if [ $# -ne 5 ]; then
    echo "Usage: $0 <jobID> <scriptsHome> <extractedFilesBase> <timeStep> <aggType>"
    return 1
fi

jobID="$1"
scriptsHome="$2"
timeStep="$4"
extractedFilesLoc="$3/t${timeStep}"
aggType=$5

# Create directory structure
mkdir -p "plots" || { echo "Error: Cannot create plots directory"; return 1; }
mkdir -p "plots/${jobID}" || { echo "Error: Cannot create plots/${jobID}"; return 1; }
mkdir -p "plots/${jobID}/${aggType}" || { echo "Error: Cannot create plots/${jobID}/${aggType}"; return 1; }

currPlotDest="plots/${jobID}/${aggType}/t${timeStep}"
mkdir -p "${currPlotDest}" || { echo "Error: Cannot create ${currPlotDest}"; return 1; }

echo "==> Side by side comparison of PP PDW ES ES_AWD ES_aggregate_info FixedMetaInfoGather transport_0.wbytes"
echo "    for default & flatten types (joined and default are pretty identical)"

detectContent()
{
    local key="$1"
    local count=$(find "${extractedFilesLoc}" -maxdepth 1 -type f -name "${key}*" | wc -l)

    if [ ${count} -gt 0 ]; then
	echo "${count} files has ${key}"
	true; return
    else
	false; return
    fi
    
}

#knownPrefixes=( 'default' 'flatten' 'joined' )

#asyncCompareOptions=()
#compareOptions=()
#for p in "${knownPrefixes[@]}"; do
#    if detectContent "$p"; then
#	compareOptions+="$p"
#    fi
#    if detectContent "async$p"; then
#	asyncCompareOptions+="async$p"
#    fi
#done

#echo ${compareOptions} ${compareOptions[1]}
#echo ${asyncCompareOptions}



compareTwo()
{
    local filePrefix=$1
    local type1=$2
    local type2=$3
    
    #path1=($(ls ${extractedFilesLoc}/${type1}*  ))
    #path2=($(ls ${extractedFilesLoc}/${type2}*  ))

    #n=$((${#path1[@]}*${#path2[@]}))

    echo "python3 ${scriptsHome}/plotRanks.py ${type1} ${type2} --set dataDir=${extractedFilesLoc} plotPrefix=${currPlotDest}/${filePrefix} jsonAttr=ES"
        python3 ${scriptsHome}/plotRanks.py ${type1} ${type2} --set dataDir=${extractedFilesLoc} plotPrefix=${currPlotDest}/${filePrefix} jsonAttr=ES
    
    python3 ${scriptsHome}/plotRanks.py ${type1} ${type2} --set dataDir=${extractedFilesLoc} plotPrefix=${currPlotDest}/${filePrefix} jsonAttr=ES_AWD
    python3 ${scriptsHome}/plotRanks.py ${type1} ${type2} --set dataDir=${extractedFilesLoc} plotPrefix=${currPlotDest}/${filePrefix} jsonAttr=ES_AWD logScale=x
    python3 ${scriptsHome}/plotRanks.py ${type1} ${type2} --set dataDir=${extractedFilesLoc} plotPrefix=${currPlotDest}/${filePrefix} jsonAttr=ES_aggregate_info levelAxis=True logScale=x

    python3 ${scriptsHome}/plotRanks.py ${type1} ${type2} --set dataDir=${extractedFilesLoc} plotPrefix=${currPlotDest}/${filePrefix} jsonAttr=FixedMetaInfoGather  logScale=xy
    python3 ${scriptsHome}/plotRanks.py ${type1} ${type2} --set dataDir=${extractedFilesLoc} plotPrefix=${currPlotDest}/${filePrefix} jsonAttr=FixedMetaInfoGather  logScale=y	
    python3 ${scriptsHome}/plotRanks.py ${type1} ${type2} --set dataDir=${extractedFilesLoc} plotPrefix=${currPlotDest}/${filePrefix} jsonAttr=FixedMetaInfoGather

    python3 ${scriptsHome}/plotRanks.py ${type1} ${type2} --set dataDir=${extractedFilesLoc} plotPrefix=${currPlotDest}/${filePrefix} jsonAttr=MetaInfoBcast

    python3 ${scriptsHome}/plotRanks.py ${type1} ${type2} --set dataDir=${extractedFilesLoc} plotPrefix=${currPlotDest}/${filePrefix} jsonAttr=PDW
    python3 ${scriptsHome}/plotRanks.py ${type1} ${type2} --set dataDir=${extractedFilesLoc} plotPrefix=${currPlotDest}/${filePrefix} jsonAttr=PP logScale=x

    python3 ${scriptsHome}/plotRanks.py ${type1} ${type2} --set dataDir=${extractedFilesLoc} plotPrefix=${currPlotDest}/${filePrefix} jsonAttr=transport_0.wbytes  whichKind=MB

    if [[ $type1 == async* ]] ; then
	python3 ${scriptsHome}/plotRanks.py ${type1} ${type2} --set dataDir=${extractedFilesLoc} plotPrefix=${currPlotDest}/${filePrefix} jsonAttr=BS_WaitOnAsync    
	python3 ${scriptsHome}/plotRanks.py ${type1} ${type2} --set dataDir=${extractedFilesLoc} plotPrefix=${currPlotDest}/${filePrefix} jsonAttr=DC_WaitOnAsync1 logScale=x
	python3 ${scriptsHome}/plotRanks.py ${type1} ${type2} --set dataDir=${extractedFilesLoc} plotPrefix=${currPlotDest}/${filePrefix} jsonAttr=DC_WaitOnAsync2 logScale=x
    fi

    echo "==> plot all the times spent on rank 0: python3 ${scriptsHome}/plotStack.py  ${type1} ${type2} --set dataDir=${extractedFilesLoc}  whichRank=0 plotPrefix=${currPlotDest}/${filePrefix}"
    python3 ${scriptsHome}/plotStack.py  ${type1} ${type2} --set dataDir=${extractedFilesLoc}  whichRank=0 plotPrefix=${currPlotDest}/${filePrefix}

    #fi
}


compareThree()
{
    local filePrefix=$1
    local type1=$2
    local type2=$3
    local type3=$4
    
    echo "==> plot all the times spent on rank 0"
    python3 ${scriptsHome}/plotStack.py  ${type1} ${type2} ${type3} --set dataDir=${extractedFilesLoc}  whichRank=0 plotPrefix=${currPlotDest}/${filePrefix}
    
    echo "==> plot numCalls occurred"
    echo "${scriptsHome}/plotCall.py ${type1} ${type2} ${type3} --set dataDir=${extractedFilesLoc} plotPrefix=${currPlotDest}/${filePrefix}"
    python3 ${scriptsHome}/plotCall.py ${type1} ${type2} ${type3} --set dataDir=${extractedFilesLoc} plotPrefix=${currPlotDest}/${filePrefix}
}

checkPossibilities()
{
    local prefix=$1
    local typeD=${prefix}"default"
    local typeF=${prefix}"flatten"
    local typeJ=${prefix}"joined"



    local trueCounter=0;
    
    hasDefault=false
    hasFlatten=false
    hasJoined=false
    
    if detectContent $typeD; then
	hasDefault=true
	trueCounter=$((trueCounter + 1))
    fi
    
    if detectContent $typeF; then
	hasFlatten=true
	trueCounter=$((trueCounter + 1))
    fi
    if detectContent $typeJ; then
	hasJoined=true
	trueCounter=$((trueCounter + 1))
    fi

    echo "trueCounter = $trueCounter"
    if [[ trueCounter -ge 2 ]]; then
	if ($hasDefault && $hasJoined); then
	    compareTwo dj $typeD $typeJ
	fi
	if ($hasDefault && $hasFlatten); then
	    compareTwo df $typeD $typeF 
	fi
	if ($hasJoined && $hasFlatten); then    
	    compareTwo jf $typeJ $typeF 
	fi
    fi

    if [[ trueCounter -eq 3 ]]; then 
	compareThree djf $typeD $typeJ $typeF 
    fi

    if [[ trueCounter -eq 1 ]]; then
	validType=$typeD
	if ${hasJoined}; then
	    validType=$typeJ
	elif ${hasFlatten}; then 
	    validType=$typeF
	fi
	compareTwo ${validType} ${validType}  ## first input is file prefix
    fi
}


checkPossibilities ""
checkPossibilities "async"




