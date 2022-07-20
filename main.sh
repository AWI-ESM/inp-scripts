#!/bin/ksh 
# Jul 2022: Creating steering script
#           J. Streffing

RES='TCO95L91'
EXPID='aack'
FESOM_MESH='CORE2'
INPATH='/work/ab0246/a270092/input/oifs-43r3/TCO95L91/'
OUTPATH='/work/ab0246/a270092/input/oifs-43r3/nudging/TCO95L91/'
POOL='/pool/data/ERA5/ml00_1H/'
CDO='/sw/spack-levante/cdo-2.0.5-5fascj/bin/cdo'
SCRIPTPATH=`pwd`
DATA_SET='era5_'
BYEAR=2017
EYEAR=2020
BMONTH=01
EMONTH=05

#./create_template_OIFS.sh $RES $EXPID $FESOM_MESH $INPATH $OUTPATH $CDO
#sbatch ${SCRIPTPATH}/preprocess_inputdata_year.sh ${CDO} ${SCRIPTPATH} ${POOL} ${OUTPATH} ${DATA_SET} ${BYEAR} ${EYEAR}
./nudging_cdo.sh $DATA_SET $RES $BYEAR $BMONTH $EYEAR $EMONTH $OUTPATH $OUTPATH $OUTPATH $SCRIPTPATH $CDO
