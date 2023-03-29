#!/bin/ksh 
# Jul 2022: Creating steering script
#           J. Streffing
# Mar 2023: update for ECMWF HPC2020
#           E. Tourigny

set -xuve
#set -ue

#RES='TCO95L91'
RES='TCO159L91'
#RES='T255L91'

#only for create_template script
#INPATH_TEMPLATE=/hpcperm/c3et/models/ecearth/v4-trunk/oifs/${RES}/19900101
#EXPID='ECE4'
INPATH_TEMPLATE=/hpcperm/c3et/ece3data/ifs/${RES}/19900101
EXPID='ECE3'
FESOM_MESH="-"

DATA_SET='era5_'
INPATH=/scratch/c3et/nudging/data/${DATA_SET}
OUTPATH=/perm/c3et/nudging/data/${DATA_SET}
POOL=/perm/c3et/nudging/data/${DATA_SET}raw #unused at ecmwf
TEMPLATES=/perm/c3et/nudging/data/templates
TMPPATH=/scratch/c3et/nudging/tmp/
CDO='cdo'
SCRIPTPATH=`pwd`
#export SUBMIT='bash'
export SUBMIT='sbatch -q nf -c 8 --mem-per-cpu=5300M -A spnlpete'
export LOAD_ENV='module load cdo/2.0.6'

mkdir -p ${TMPPATH}
cd ${TMPPATH}

${LOAD_ENV}

# script to create template file for a given resolution, run only once
#bash ${SCRIPTPATH}/create_template_OIFS.sh $RES $EXPID $FESOM_MESH ${INPATH_TEMPLATE} $TEMPLATES $CDO

# datelist setup
BYEAR=2000
EYEAR=2000
BMONTH=02
EMONTH=02

# use this script to format data at AWI - this could be replaced by (untested)
#grib_copy -w dataTime=0/6/12/18 E5ml00_1H_${year}-${month}-*_{129,130,138,152,155} [dataDate][dataTime].sp
#grib_copy -w dataTime=0/6/12/18 E5ml00_1H_${year}-${month}-*_133 [dataDate][dataTime].gp
#bash ${SCRIPTPATH}/preprocess_inputdata_year.sh ${CDO} ${SCRIPTPATH} ${POOL} ${INPATH} ${DATA_SET} ${BYEAR} ${EYEAR}

# main interpolation script (old)
#bash ${SCRIPTPATH}/nudging_cdo.sh $DATA_SET $RES $BYEAR $BMONTH $EYEAR $EMONTH $INPATH $TEMPLATES $OUTPATH/${RES} $SCRIPTPATH $CDO

#new workflow calling scripts for individual months directly at ECMWF
for CYEAR in `seq ${BYEAR} ${EYEAR}`
do
  for mon in `seq ${BMONTH} ${EMONTH}`
  do
    MONTH=$(printf "%02d" $mon)
    #uncomment to download data
    #bash ${SCRIPTPATH}/get_inputdata_mars.sh ${INPATH} ${DATA_SET} ${CYEAR} ${MONTH}
    bash ${SCRIPTPATH}/int_cdo.sh ${CDO} ${TEMPLATES}/template.oifs${RES} ${DATA_SET} ${SCRIPTPATH} ${RES} ${INPATH}/${DATA_SET}${CYEAR}${MONTH} ${OUTPATH}/${RES} ${TMPPATH}/${DATA_SET}${CYEAR}${MONTH}/tmp_${DATA_SET}${RES}
  done
done
