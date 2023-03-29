#!/bin/sh 
# Subroutine called by preprocess_inputdata.sh
# 
# M. Athanase, H. Goessling
######################################################################## 

set -xuve

CDO=$1 		# path to CDO module
SCRIPTPATH=$2 	# path to script folder
POOL=$3 	# path to raw reanalysis data
OUTPATH=$4	# path to output the monthly reanalysis data

NDGTAG=$5       # TAG of nudging data, e.g. era5_ or analogous
BYEAR=$6        # First year to preprocess
EYEAR=$7	# Year at which the preprocessing ends


YEAR=$BYEAR

# Go through all years until end-year
while [ $YEAR -lt $EYEAR ] 
do
   echo 'Starting YEAR: '$YEAR
   CMONTH=1
   while [ $CMONTH -le 12 ]
   do

      if [ $CMONTH -lt 10 ]; then
         MONTH='0'${CMONTH}
         echo 'Starting MONTH: '$MONTH
      fi
      if [ $CMONTH -ge 10 ]; then
         MONTH=${CMONTH}
         echo 'Starting MONTH: '$MONTH
      fi

      # Create folder to be archived
      NDGPATH=${OUTPATH}/${NDGTAG}${YEAR}${MONTH}/
      mkdir -p ${NDGPATH}
      echo 'Folder '${NDGPATH}' created'
      # Execute preprocessing by monthly chunks
      ${SUBMIT} ${SCRIPTPATH}/preprocess_inputdata_month.sh ${CDO} ${SCRIPTPATH} ${POOL} ${NDGPATH} ${NDGTAG} ${YEAR} ${MONTH}
      CMONTH=`expr $CMONTH + 1`
   done
   YEAR=`expr $YEAR + 1`
done
exit
