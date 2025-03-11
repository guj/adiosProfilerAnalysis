dir=$1

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
		tt=`grep Total $eachTest |grep -v GPU `
		echo "=> Report: $eachTestDir $eachTest ...  ${tt}"
	    done
	    popd
	fi
      done
      popd
    fi
done

popd
