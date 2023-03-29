#!/bin/ksh
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
RES=$4
CYEAR=$5
MONTH=$6
INPATH=$7
TEMPLATEPOOL=$8
OUTPATH=$9
# Successive interpolation of nudging data (era5).
# Interpolation of a particular month MONTH is done for BYEAR to EYEAR
# Calls int_cdo.sh

mkdir -p ${OUTPATH}/sh ${OUTPATH}/gg

ERAMONTHDIR=${INPATH}/${NDGTAG}${CYEAR}${MONTH}
mkdir -p $ERAMONTHDIR/tmp_${NDGTAG}${RES}

cd $ERAMONTHDIR

# Splitting monthly input files in timestep files
${CDO} -splitsel,1 ${NDGTAG}${CYEAR}${MONTH}.gp $ERAMONTHDIR/tmp_${NDGTAG}${RES}/${NDGTAG}${CYEAR}${MONTH}_gp_$$_
${CDO} -splitsel,1 ${NDGTAG}${CYEAR}${MONTH}.sp $ERAMONTHDIR/tmp_${NDGTAG}${RES}/${NDGTAG}${CYEAR}${MONTH}_sp_$$_

# Saving timestamp
${CDO} showtimestamp ${NDGTAG}${CYEAR}${MONTH}.sp > list_$$.txt
times=($(cat list_$$.txt))
rm list_$$.txt

cd $ERAMONTHDIR/tmp_${NDGTAG}${RES}/

# Renaming 
x=0;
for f in $(ls ${NDGTAG}${CYEAR}${MONTH}_sp_$$_*);
do
  timescorr=$(echo ${times[x]} | awk -F "T" '{print $1" "$2}')
  timesstr=$(echo "$(date +%Y%m%d%H%M -d "${timescorr}")");
  mv $f ${NDGTAG}${timesstr}.sp;
  let x=$x+1;
done

x=0;
for f in $(ls ${NDGTAG}${CYEAR}${MONTH}_gp_$$_*);
do
  timescorr=$(echo ${times[x]} | awk -F "T" '{print $1" "$2}')
  timesstr=$(echo "$(date +%Y%m%d%H%M -d "${timescorr}")");
  mv $f ${NDGTAG}${timesstr}.gp;
  let x=$x+1;
done

# Beging interpolation at each time step  
${SCRIPTPATH}/int_cdo.sh ${CDO} ${TEMPLATEPOOL}/template.oifs${RES} ${NDGTAG} ${SCRIPTPATH} ${RES} $ERAMONTHDIR/tmp_${NDGTAG}${RES}/ ${OUTPATH} # >> int_cdo.aus

#rm -rf $ERAMONTHDIR/tmp_${NDGTAG}${RES}/
exit
