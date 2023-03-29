#!/bin/bash
#
# Feb 2011:     Original implementation of the CDO command sequence for
#               preparing nudging files for ECHAM
#               S. Rast, A. Voigt, U. Schulzweida
#
# May 2021:     Adapting the CDO sequence for 
#               preparing nudging files for OIFS
#               M. Athanase
######################################################################## 

#set -xuve
set -ue

SCRIPTPATH=$1
CDO=$2
NDGTAG=$3
INPATH=$4
RES=$5
BYEAR=$6
EYEAR=$7
MONTH=$8
TEMPLATEPOOL=$9
OUTPATH=${10}

# Successive interpolation of nudging data (era5).
# Interpolation of a particular month MONTH is done for BYEAR to EYEAR
# Calls int_cdo.sh
if [ ${#MONTH} -gt 1 ]; then
   if [ $MONTH -lt 1 -o $MONTH -gt 12 ]; then
       echo 'MONTH out of range, MONTH='$MONTH
       exit
   fi
fi
if [ ${#BYEAR} -lt 4 ]; then
    BYEAR=2000
    EYEAR=2000
    MONTH=1
fi
if [ ${#EYEAR} -lt 4 ]; then
    EYEAR=$BYEAR
    MONTH=1
fi
if [ ${#MONTH} -lt 1 ]; then
    MONTH=1
fi
if [ ${#MONTH} -eq 1 ]; then
    MONTH=0$MONTH
fi
CYEAR=$BYEAR
while [ $CYEAR -le $EYEAR ]
do
   echo 'YEAR= '$CYEAR' MONTH='$MONTH
   ERAMONTHDIR=${NDGTAG}${CYEAR}${MONTH}
   cd ${INPATH}
   if [ ! -d $ERAMONTHDIR ]; then
       echo 'Reanalysis data for the month '${CYEAR}${MONTH}' has not been preprocessed! Call preprocess_inputdata.sh first.'
       exit 1
   fi
   cd $ERAMONTHDIR
   ${SCRIPTPATH}/nudging_int_month_timestep_cdo.sh ${SCRIPTPATH} ${CDO} ${NDGTAG} ${RES} ${CYEAR} ${MONTH} ${INPATH} ${TEMPLATEPOOL} ${OUTPATH} # >> nudging_int_month_timestep_cdo.aus 
   CYEAR=`expr $CYEAR + 1`
done
exit
