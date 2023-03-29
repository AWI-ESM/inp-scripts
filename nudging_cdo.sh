#!/bin/ksh
#
# Feb 2011: 	Original implementation of the CDO command sequence for
# 		preparing nudging files for ECHAM
# 		S. Rast, A. Voigt, U. Schulzweida
#
# Oct 2021: 	Adaptation of the CDO sequence for the 
# 		preparation of nudging files for OpenIFS
# 		M. Athanase, H. Goessling
#
# May 2022: 	Fix minor issues to allow file preparation for all grid 
#		resolutions
#		M. Athanase, H. Goessling
#
# Scripts description and usage in README
######################################################################## 

#set -xuve
set -ue

NDGTAG=$1            # TAG of nudging data, e.g. era5_ or analogous
RES=$2               # resolution of interpolated nudging data, e.g. TCO159L91
BYEAR=$3             # first year to interpolate
BMONTH=$4            # first month in $BYEAR
EYEAR=$5             # last year to interpolate
EMONTH=$6            # last month in $EYEAR
INPATH=$7
TEMPLATEPOOL=$8
OUTPATH=$9
SCRIPTPATH=${10}
CDO=${11}

mkdir -p ${OUTPATH}

echo 'SCRIPTPATH '$SCRIPTPATH 
echo 'CDO '$CDO 
echo 'INPATH '$INPATH 
echo 'NDGTAG '$NDGTAG 
echo 'RES '$RES 
echo 'BYEAR '$BYEAR 
echo 'BMONTH '$BMONTH 
echo 'EYEAR '$EYEAR 
echo 'EMONTH '$EMONTH 
echo 'TEMPLATEPOOL '$TEMPLATEPOOL 
echo 'OUTPATH '$OUTPATH

echo ' '
echo 'interpolating data, start nudging_int_cdo.sh'
${SCRIPTPATH}/nudging_int_cdo.sh $SCRIPTPATH $CDO $INPATH $NDGTAG $RES $BYEAR $BMONTH $EYEAR $EMONTH $TEMPLATEPOOL $OUTPATH

