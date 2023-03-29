#!/bin/ksh
# Feb 2011:     Original implementation of the CDO command sequence for
#               preparing nudging files for ECHAM
#               S. Rast, A. Voigt, U. Schulzweida
#
######################################################################

#set -xuve
set -ue

SCRIPTPATH=$1
CDO=$2
INPATH=$3
NDGTAG=$4
RES=$5
BYEAR=$6
BMONTH=$7
EYEAR=$8
EMONTH=${9}
TEMPLATEPOOL=${10}
OUTPATH=${11}

# Interpolation of ECMWF data for nudging within OIFS. 
# - Up to twelve months are interpolated in parallel. 
# - The years are treated successively.
# - Calls nudging_int_month.sh
if [ ${#BMONTH} -gt 1 ]; then
   if [ $BMONTH -lt 1 -o $BMONTH -gt 12 ]; then
       echo 'BMONTH out of range, BMONTH='$BMONTH
       exit
   fi
fi
if [ ${#EMONTH} -gt 1 ]; then
   if [ $EMONTH -lt 1 -o $EMONTH -gt 12 ]; then
       echo 'EMONTH out of range, EMONTH='$EMONTH
       exit
   fi
fi
if [ ${#BYEAR} -lt 4 ]; then
    BYEAR=2000
    BMONTH=1
    EYEAR=2000
    EMONTH=12
fi
if [ ${#BMONTH} -lt 1 ]; then
    BMONTH=1
    EYEAR=$BYEAR
    EMONTH=12
fi
if [ ${#EYEAR} -lt 4 ]; then
    EYEAR=$BYEAR
    EMONTH=12
fi
if [ ${#EMONTH} -lt 1 ]; then
    EMONTH=12
fi
#rm -f ${NDGTAG}_int_month.aus
CMONTH=1
while [ $CMONTH -le 12 ]
do
   BYEAR_MONTH=$BYEAR
   if [ $CMONTH -lt $BMONTH ]; then
      BYEAR_MONTH=`expr $BYEAR_MONTH + 1`
   fi
   EYEAR_MONTH=$EYEAR
   if [ $CMONTH -gt $EMONTH ]; then
      EYEAR_MONTH=`expr $EYEAR_MONTH - 1`
   fi
   ${SCRIPTPATH}/nudging_int_month_cdo.sh $SCRIPTPATH $CDO $NDGTAG $INPATH $RES $BYEAR_MONTH $EYEAR_MONTH $CMONTH $TEMPLATEPOOL $OUTPATH # >> ${NDGTAG}_int_month_cdo.aus &
   CMONTH=`expr $CMONTH + 1`
done
exit
