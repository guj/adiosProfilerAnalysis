#!/bin/bash
[ -z "$1" ] && { echo "Error: Directory argument required"; exit 1; }
dir="$1"

pushd "$dir" || { echo "Error: Cannot change to directory $dir"; exit 1; }

listByAgg()
{
    local eachTestDir="$1"
    local aggType="$2"

    howmany=`ls * |grep $aggType | wc | awk '{print $1}'`
    if [ $howmany -ne  0 ]; then 
            for eachTest in *"$aggType"*; 
            do
		if [[ "$eachTest" != "#"* ]]; then
		     numES=$(jq '.[] | .ES.nCalls' $eachTest  | head -1)
		     numPP=$(jq '.[] | .PP.nCalls' $eachTest  | head -1)		    
		     numPDW=$(jq '.[] | .PDW.nCalls' $eachTest  | head -1) 

		     if [[ $numPP == "null" ]];
		     then
			 echo "... $eachTest     est_total=" $estimated "numES=" ${numES}  " numPDW=" ${numPDW}
		     elif [[ $numPDW == "null" ]];
		     then
			  echo "... $eachTest     est_total=" $estimated "numES=" ${numES} " numPP=" ${numPP} 
		     else
			 echo "... $eachTest     est_total=" $estimated "numES=" ${numES} " numPP=" ${numPP} " numPDW=" ${numPDW}
		     fi
                     
		     if [[ $eachTestDir == *async* ]]; then
			 sync1Time=$(jq '.[] | .DC_WaitOnAsync1_mus' $eachTest  |  sort -n | tail -1 | awk '{print $1/1000000}')
			 sync2Time=$(jq '.[] | .DC_WaitOnAsync2_mus' $eachTest  |  sort -n | tail -1 | awk '{print $1/1000000}')
			 bsSyncTime=$(jq '.[] | .BS_WaitOnAsync_mus' $eachTest  |  sort -n | tail -1 | awk '{print $1/1000000}')
			 echo "....                   wait1=$sync1Time wait2 = $sync2Time  bs_wait=$bsSyncTime"
		     fi
                fi
            done
    fi
    echo ""

}

for eachEntry in *; 
do
    echo "=> $eachEntry"
    if [ -d "${eachEntry}" ]; then
      pushd ${eachEntry}
      for eachTestDir in *;
      do
	  if [ -d "${eachTestDir}" ]; then 
	      echo "  Testdir=" $eachTestDir
	      if [ -d "${eachTestDir}/jsons" ]; then
		  pushd ${eachTestDir}/jsons/*
		  echo "=====> report: $eachTestDir .. ...  "

		  listByAgg "${eachTestDir}" tls
		  listByAgg "${eachTestDir}" ews

		  popd || exit 1
	      fi
	  fi
      done
      popd || exit 1
    fi
done

popd || exit 1
