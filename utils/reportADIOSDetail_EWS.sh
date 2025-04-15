#!/bin/bash
[ -z "$1" ] && { echo "Error: Directory argument required"; return 1; }
dir="$1"

pushd "$dir" || { echo "Error: Cannot change to directory $dir"; return 1; }

findTime()
{
    local attrName="$1"
    local fileName="$2"

    min=$(jq -r ".[] | ${attrName}" "${fileName}" | awk '{print $1/1000000}' | sort -n | tail -1)
    max=$(jq -r ".[] | ${attrName}" "${fileName}" | awk '{print $1/1000000}' | sort -n | head -1)

    echo "${attrName}, min/max=$min, $max"
}

listByAgg()
{
    local eachTestDir="$1"
    local aggType="$2"
    
    howmany=$(ls * |grep $aggType | wc | awk '{print $1}')
    if [ "$howmany" -ne 0 ]; then
            for eachTest in `ls *$aggType* `;
            do
		if [[ "$eachTest" != "#"* ]]; then
                #if [ $eachTest != \#* ]; then
                     estimated=$(jq '.[] | .ES_mus +  .PDW_mus + .PP_mus' $eachTest |  sort -n | tail -1 | awk '{print $1/1000000}')
		     
                     numES=$(jq '.[] | .ES.nCalls' $eachTest  | head -1)
		     
                     numPP=$(jq '.[] | .PP.nCalls' $eachTest  | head -1)
		     
                     numPDW=$(jq '.[] | .PDW.nCalls' $eachTest  | head -1)

		     findTime ".ES_mus"  "$eachTest"
		     
                     echo "... $eachTest     est_total=" $estimated "numES=" ${numES} " numPP=" ${numPP} " numPDW=" ${numPDW}
		     if [[ "$eachTestDir" == *async* ]]; then
			 echo "jq '.[] | .DC_WaitOnAsync1_mus' $eachTest |  sort -n | tail -1 | awk '{print $1/1000000}'"
			 sync1Time=$(jq '.[] | .DC_WaitOnAsync1_mus' "$eachTest" | sort -n | tail -1 | awk '{print $1/1000000}')
			 sync2Time=$(jq '.[] | .DC_WaitOnAsync2_mus' "$eachTest" | sort -n | tail -1 | awk '{print $1/1000000}')
			 bsSyncTime=$(jq '.[] | .BS_WaitOnAsync_mus' "$eachTest" | sort -n | tail -1 | awk '{print $1/1000000}')
			 echo "....                   wait1=$sync1Time wait2=$sync2Time bs_wait=$bsSyncTime"              
		     fi
                fi
            done
    fi
    echo ""

}

#for eachEntry in `ls`;
for eachEntry in *; 
do
    #echo "=> $eachEntry"
    if test -d ${eachEntry}/; then
      pushd ${eachEntry} || continue
      echo "...... in ${eachEntry}"
      #for eachTestDir in `ls |grep _flatt`;
      #for eachTestDir in `ls `;
      for eachTestDir in *;
      do
	echo "  Testdir=" $eachTestDir
	if test -d ${eachTestDir}/jsons; then
	    pushd ${eachTestDir}/jsons/*
	    echo "=> report: $eachTestDir .. ...  "
	    
	    listByAgg $eachTestDir ews

	    popd
	else
	    echo "${eachTestDir}/jsons is not a dir"
	fi
      done
      popd || return 1
    fi
done

popd || return 1
