#!/bin/ksh
#
# Subroutine called by preprocess_inputdata_year.sh
#
# M. Athanase, H. Goessling
######################################################################## 

set -xuve

CDO=$1 		    # path to CDO module
SCRIPTPATH=$2 	    # path to script folder
POOL=$3  	    # path to raw reanalysis data
NDGPATH=$4 	    # path to the monthly subfolder to output the 
		    # preprocessed reanalysis data

NDGTAG=$5           # TAG of nudging data, e.g. era5_ or analogous
YEAR=$6             # year to preprocess
MONTH=$7	    # month to preprocess

# performs the subsampling (6-hourly) and monthly re-packaging of the 
# reanalysis data
echo 'monthly pre-processing input files, start preprocess_inputdata_month.sh'

mkdir -p ${NDGPATH}

   # Preparation of spectral input files

#eval ${CDO} -P 8 -merge [ -mergetime -apply,-seltimestep,1/24/6 [ ${POOL}/${YEAR}/*_1H_${YEAR}-${MONTH}-*_129 ] ] [ -mergetime -apply,-seltimestep,1/24/6 [ ${POOL}/${YEAR}/*_1H_${YEAR}-${MONTH}-*_152 ] ] [ -mergetime -apply,-seltimestep,1/24/6 [ ${POOL}/${YEAR}/*_1H_${YEAR}-${MONTH}-*_130 ] ] [ -mergetime -apply,-seltimestep,1/24/6 [ ${POOL}/${YEAR}/*_1H_${YEAR}-${MONTH}-*_138 ] ] [ -mergetime -apply,-seltimestep,1/24/6 [ ${POOL}/${YEAR}/*_1H_${YEAR}-${MONTH}-*_155 ] ] ${NDGPATH}/${NDGTAG}${YEAR}${MONTH}.sp

# workaround for "merge does not work well with Argument Groups"
# https://code.mpimet.mpg.de/boards/1/topics/14213

#rm -f ${NDGPATH}/${NDGTAG}${YEAR}${MONTH}-*.sp ${NDGPATH}/${NDGTAG}${YEAR}${MONTH}.sp
#for v in 129 152 130 138 155 ; do
#    eval ${CDO} -O -P 8 -mergetime -apply,-seltimestep,1/24/6 [ ${POOL}/${v}/*_1H_${YEAR}-${MONTH}-*_${v}.grb ] ${NDGPATH}/${NDGTAG}${YEAR}${MONTH}-${v}.sp
#done
#eval ${CDO} -O -P 8 -merge ${NDGPATH}/${NDGTAG}${YEAR}${MONTH}-*.sp ${NDGPATH}/${NDGTAG}${YEAR}${MONTH}.sp
#rm -f ${NDGPATH}/${NDGTAG}${YEAR}${MONTH}-*.sp

   # Preparation of grid-point input files
#eval ${CDO} -O -P 8 -mergetime -apply,-seltimestep,1/24/6 [ ${POOL}/133/*_1H_${YEAR}-${MONTH}-*_133.grb ] ${NDGPATH}/${NDGTAG}${YEAR}${MONTH}.gp 


# Splitting monthly input files in timestep files
${CDO} -splitsel,1 ${NDGPATH}/${NDGTAG}${YEAR}${MONTH}.gp ${NDGPATH}/${NDGTAG}${YEAR}${MONTH}_gp_$$_
${CDO} -splitsel,1 ${NDGPATH}/${NDGTAG}${YEAR}${MONTH}.sp ${NDGPATH}/${NDGTAG}${YEAR}${MONTH}_sp_$$_

# Saving timestamp
${CDO} showtimestamp ${NDGPATH}/${NDGTAG}${YEAR}${MONTH}.sp > ${NDGPATH}/list_$$.txt
times=($(cat ${NDGPATH}/list_$$.txt))
rm ${NDGPATH}/list_$$.txt

cd ${NDGPATH}/

# Renaming 
x=0;
for f in $(ls ${NDGTAG}${YEAR}${MONTH}_sp_$$_*);
do
  timescorr=$(echo ${times[x]} | awk -F "T" '{print $1" "$2}')
  timesstr=$(echo "$(date +%Y%m%d%H%M -d "${timescorr}")");
  mv $f ${timesstr}.sp;
  let x=$x+1;
done

x=0;
for f in $(ls ${NDGTAG}${YEAR}${MONTH}_gp_$$_*);
do
  timescorr=$(echo ${times[x]} | awk -F "T" '{print $1" "$2}')
  timesstr=$(echo "$(date +%Y%m%d%H%M -d "${timescorr}")");
  mv $f ${timesstr}.gp;
  let x=$x+1;
done

cd ${SCRIPTPATH}

