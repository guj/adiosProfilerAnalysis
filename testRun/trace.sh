#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Error: 2 arguments required"
    echo "Usage: $0 <scriptHome> whichRank whichJasonFile"
    return 1

fi



upToRank=$1
whichJsonFile=$2

knownTracerAttrs=( 'ES' 'FixedMetaInfoGather' )

for whichRank in $(seq 0 ${upToRank}); do
  #echo $whichRank    
  for attrName in ${knownTracerAttrs[@]}; do
    prefix=/tmp/${attrName}_${whichRank}
    jq -r ".[] | select(.rank == ${whichRank}) " ${whichJsonFile} | jq .${attrName}.trace | jq -r ".[]"  | sed  's/+/ /g'| awk '{print $1}'> ${prefix}.start
    jq -r ".[] | select(.rank == ${whichRank}) " ${whichJsonFile} | jq .${attrName}.trace | jq -r ".[]"  | sed  's/+/ /g'| awk '{print $2}'> ${prefix}.dur
    #echo "produced ${prefix}.*"
    #more ${prefix}.dur | paste -sd+ - | bc 
  done

done
