dir=$1

pushd $dir

listByAgg()
{
    eachTestDir=$1
    aggType=$2
    howmany=`ls * |grep $aggType | wc | awk '{print $1}'`
    if [ $howmany != 0 ]; then 
            for eachTest in `ls *$aggType* `;
            do
                if [ $eachTest != \#* ]; then
                     #echo "  $eachTest ...  "
                     isGood=`grep "\[" $eachTest | wc | awk '{print $1}'`
		     
                     ## isGood=1 if [ is found at start of file                                                                                                                              
                     ## then we need to process it                                                                                                                                           
                     if [ "$isGood" = "1" ];  then
                         sed -i -e 's/\[/ /' $eachTest
                         sed -i -e 's/\]/ /' $eachTest
                         sed -i -e 's/\} \}\,/\} \} /' $eachTest
                     fi
                     estimated=`jq '.ES_mus +  .PDW_mus + .PP_mus' $eachTest |  sort -n | tail -1 | awk '{print $1/1000000}'`
		     
                     numES=`jq '.ES.nCalls' $eachTest  | head -1`
		     
                     numPP=`jq '.PP.nCalls' $eachTest  | head -1`
		     
                     numPDW=`jq '.PDW.nCalls' $eachTest  | head -1`
		     
                     echo "... $eachTest     est_total=" $estimated "numES=" ${numES} " numPP=" ${numPP} " numPDW=" ${numPDW}
		     if [[ $eachTestDir == *async* ]]; then
			 sync1Time=`jq '.DC_WaitOnAsync1_mus' $eachTest |  sort -n | tail -1 | awk '{print $1/1000000}'`
			 sync2Time=`jq '.DC_WaitOnAsync2_mus' $eachTest |  sort -n | tail -1 | awk '{print $1/1000000}'`
			 bsSyncTime=`jq '.BS_WaitOnAsync_mus' $eachTest |  sort -n | tail -1 | awk '{print $1/1000000}'`
			 echo "....                   wait1=$sync1Time wait2 = $sync2Time  bs_wait=$bsSyncTime"
		     fi
                     #for key in "${keyNames[@]}";                                                                                                                                           
                     #do                                                                                                                                                                     
                     #pc=`grep $key -i $eachTest |grep -v MiB |  tail -1 | awk '{print "nCalls=",  $2,  "min=", $3, "avg=", $4, "max=", $5}'`                                                
                     #echo "\t${key}  \t ${pc}"                                                                                                                                              
                     #done                                                                                                                                                                   
                fi
            done
    fi
    echo ""

}

for eachEntry in `ls`; 
do
    #echo "=> $eachEntry"
    if test -d ${eachEntry}/; then
      pushd ${eachEntry}
      for eachTestDir in `ls `;
      do
	#echo "  Testdir=" $eachTestDir
	if test -d ${eachTestDir}/jsons; then
	    pushd ${eachTestDir}/jsons/*
	    echo "=> report: $eachTestDir .. ...  "

	    listByAgg $eachTestDir tls
	    listByAgg $eachTestDir ews

	    popd
	fi
      done
      popd
    fi
done

popd
