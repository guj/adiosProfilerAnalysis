###########################################################################
## sample usage:
## > source compare.sh ES ../jsons/testMe_default ../jsons/testMe_flatten
###########################################################################
outDir=outs
mkdir ${outDir}


processFile() {
    local filePath=$1
    local attrName=$2


    local key="joined"
    if [[ "$filePath" == *"flatten"* ]]; then
	key="flatten"
    fi
    if [[ "$filePath" == *"default"* ]]; then
	key="default"
    fi

    echo "Processing $filePath, $attrName key= $key"
    
    if [[ $attrName == *bytes* ]]; then
	jq .$attrName $filePath | awk '{print $1/1048576}' > ${outDir}/${key}_MB_${attrName}
    else    
	local attrMus=${attrName}_mus
	local attrNCalls=${attrName}.nCalls

	echo "both $attrMus  $attrNCalls"
	jq .$attrMus $filePath | awk '{print $1/1000000}' > ${outDir}/${key}_secs_${attrName}

	## use awk to divide by 1 to make sure nulls becomes 0 (e.g. if PDW is not present, jq returns null, awk makes it 0)
	jq .$attrNCalls $filePath | awk '{print $1/1}'> outs/${key}_nCalls_${attrName}
    fi

}

if ((  $# <  2 )); then
    echo "Expecting: $0 jsonProperty file1 .."
else
    numFiles=$(($# - 1))
    echo "Num Files: $numFiles"

    if [[ $1 == "all" ]]; then
	knownAttrs=( 'PP' 'PDW' 'ES' 'ES_AWD' 'ES_aggregate_info' 'FixedMetaInfoGather' 'transport_0.wbytes' )
    else
	knownAttrs=($1)
    fi
    echo "$knownAttrs"
    
    for ((i = 2; i <= $#; i++ )); do
	currFile=$argv[i]
	for currAttr in ${knownAttrs[@]}; do
	    processFile $currFile $currAttr
	done
    done
fi
