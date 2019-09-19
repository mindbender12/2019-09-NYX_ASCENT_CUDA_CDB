#!/bin/bash

#source ./env.sh
#start=$(date +%s)
#while [ ! -d ${BASE_PATH}/opt/nyx/src/Exec/LyA/bp_example_00000 ]
#do
#reset
#echo "Your job hasn't yet started generating output. Checking job status..."
#jobstat -u $(whoami)
#echo ==============================================
#echo  Elapsed time $(( $(date +%s) - ${start} )) seconds 
#echo ==============================================
#sleep 5
#if [ "$(( $(date +%s) - ${start} ))" -gt "600" ]; then
#  echo Job ran over 10 minutes. Should run \< 3min.
#  echo Recommend aborting job listed above.
#  exit 1
#fi
#done
#reset
#echo Validation := \"At least one valid output file is generated.\"
#echo SUCCESS
#echo Output location: ${BASE_PATH}/opt/nyx/src/Exec/LyA/
#echo ====================================================
#echo all compiled software will persist in the OPT_PATH
#echo BASE_PATH = ${BASE_PATH}/opt
#echo ====================================================
