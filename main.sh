#!/bin/bash
#
# Jul 2024: Creating steering script with sourced config files
# 	    J. Streffind, E. Tourigny, M. Athanase
#
#
################################################################
#
# Warning: This steering script needs to be modified for each
#          platform/HPC. Please edit required lines, as 
#          indicated by comments "USER EDIT REQUIRED".
#
################################################################


## USER EDIT REQUIRED ##
#source config/ecmwf_hpc2020.sh
source config/dkrz_levante.sh

cd ${TMPPATH}


${LOAD_ENV}

## USER EDIT REQUIRED ##
## Comment/uncomment the line below to create template file for a given resolution, run only once for a new resolution

#bash ${SCRIPTPATH}/create_template_OIFS.sh $RES $EXPID $FESOM_MESH ${INPATH_TEMPLATE} $TEMPLATES $CDO
#exit 0


## use this script to format data used at AWI instead of downloading from mars using get_inputdata_mars.sh script
## this could be replaced by (untested)
#grib_copy -w dataTime=0/6/12/18 E5ml00_1H_${year}-${month}-*_{129,130,138,152,155} [dataDate][dataTime].sp
#grib_copy -w dataTime=0/6/12/18 E5ml00_1H_${year}-${month}-*_133 [dataDate][dataTime].gp
#bash ${SCRIPTPATH}/preprocess_inputdata_year.sh ${CDO} ${SCRIPTPATH} ${POOL} ${INPATH} ${DATA_SET} ${BYEAR} ${EYEAR}


## New workflow calling scripts for individual months directly at ECMWF
for CYEAR in `seq ${BYEAR} ${EYEAR}`
do
  for mon in `seq ${BMONTH} ${EMONTH}`
  do
    MONTH=$(printf "%02d" $mon)
    script="int_${DATA_SET}${RES}_${CYEAR}${MONTH}.sh"
    rm -f ${script}

    if [ "$DATASOURCE" == "MARS" ]; then
	echo "Data source is MARS"
        cat > ${script} <<EOF
#!/bin/bash

export SUBMIT='bash'
export LOAD_ENV='${LOAD_ENV}'
bash ${SCRIPTPATH}/get_inputdata_mars.sh ${INPATH} ${DATA_SET} ${CYEAR} ${MONTH}
bash ${SCRIPTPATH}/int_cdo.sh ${CDO} ${TEMPLATES}/template.oifs${RES} ${DATA_SET} ${SCRIPTPATH} ${RES} ${INPATH}/${DATA_SET}${CYEAR}${MONTH} ${OUTPATH}/${RES} ${TMPPATH}/${DATA_SET}${CYEAR}${MONTH}/tmp_${DATA_SET}${RES}
EOF
    elif [ "$DATASOURCE" == "POOL" ]; then
	echo "Data source is POOL"
        cat > ${script} <<EOF
#!/bin/bash

export SUBMIT='bash'
export LOAD_ENV='${LOAD_ENV}'
bash ${SCRIPTPATH}/get_inputdata_pool.sh ${CDO} ${SCRIPTPATH} ${POOL} ${INPATH}/${DATA_SET}${CYEAR}${MONTH} ${DATA_SET} ${CYEAR} ${MONTH}
bash ${SCRIPTPATH}/int_cdo.sh ${CDO} ${TEMPLATES}/template.oifs${RES} ${DATA_SET} ${SCRIPTPATH} ${RES} ${INPATH}/${DATA_SET}${CYEAR}${MONTH} ${OUTPATH}/${RES} ${TMPPATH}/${DATA_SET}${CYEAR}${MONTH}/tmp_${DATA_SET}${RES}
#rm ${INPATH}/${DATA_SET}${CYEAR}${MONTH}
EOF
    fi
    ${SUBMIT} ${script}
  done
done
