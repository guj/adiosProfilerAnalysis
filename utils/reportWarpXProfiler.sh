dir=$1

keyNames=("WriteToFile()" "ParticleCounter" "WriteOpenPMDFields" "WriteOpenPMDPartic")

pushd $dir

for eachEntry in `ls`; 
do
    echo "====> $eachEntry"
    if test -d ${eachEntry}/; then
      pushd ${eachEntry}
      for eachTestDir in `ls `;
      do
	#echo "  Testdir=" $eachTestDir
	if test -d ${eachTestDir}/outs; then
	    pushd ${eachTestDir}/outs

	    for eachTest in `ls `;
	    do
		echo "=> Report: $eachTestDir $eachTest ...  "
		for key in "${keyNames[@]}";
		do
		  pc=`grep $key -i $eachTest |grep -v MiB |  tail -1 | awk '{print "nCalls=",  $2,  "max=", $5, "avg=", $4, "min=", $3}'`
	          echo "\t${key}  \t ${pc}"
		done
	    done
	    popd
	fi
      done
      popd
    fi
done

popd
