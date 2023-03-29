#!/bin/sh 
#
# Get raw reanalysis data using mars
# 
# E. Tourigny
######################################################################## 

#set -xuve
set -ue

OUTPATH=$1	# path to output the monthly reanalysis data
NDGTAG=$2       # TAG of nudging data, e.g. era5_ or analogous
YEAR=$3
MONTH=$4

# Create folder to be archived
NDGPATH=${OUTPATH}/${NDGTAG}${YEAR}${MONTH}
mkdir -p ${NDGPATH}
echo 'Folder '${NDGPATH}' created'

# Execute by monthly chunks
date_start=${YEAR}${MONTH}01
#date_end=`date --date="${date_start} +1 month -1 day" "+%Y%m%d"`
date_end=`date --date="${date_start} +3 day -1 day" "+%Y%m%d"`

script_mars=dirmars_${date_start}_${date_end}
cat > ${script_mars} << **EOF**
retrieve,type=an,levtype=ml,levelist=1/to/137,date=${date_start}/to/${date_end},time=00/06/12/18,
step=0,param=129.128/130.128/138.128/152.128/155.128,resol=av,expver=0001,class=ea,
#target="${NDGPATH}/${NDGTAG}${YEAR}${MONTH}.sp",repres=sh
target="${NDGPATH}/{dataDate}{dataTime}.sp",repres=sh
retrieve,type=an,levtype=ml,levelist=1/to/137,date=${date_start}/to/${date_end},time=00/06/12/18,
step=0,param=133.128,resol=av,expver=0001,class=ea,
#target="${NDGPATH}/${NDGTAG}${YEAR}${MONTH}.gp",repres=gg
target="${NDGPATH}/{dataDate}{dataTime}.gp",repres=gg
**EOF**
cat ${script_mars}
MARS_MULTITARGET_STRICT_FORMAT=1 mars < ${script_mars}
