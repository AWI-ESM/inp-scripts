#!/bin/bash
# Jul 2022: Creating steering script
#           J. Streffing
# Mar 2023: update for ECMWF HPC2020
#           E. Tourigny
# Jul 2024: Split into config and main scripts
#           J. Streffing

set -xuve
#set -ue

## USER EDIT REQUIRED ##
## configuration options for this run: dataset, resolution 
## and dates (first/last year and first/last month)
DATA_SET='era5_'
RES='TCO95L91'
BYEAR=2015
EYEAR=2015
BMONTH=01
EMONTH=01

## USER EDIT REQUIRED ##
## main configuration options, adapt to your user/environment
MAINPATH=/work/ba1264/a270216/INP_SCRIPTS_ET/inp-scripts/
INPATH=${MAINPATH}/nudging/${DATA_SET}raw
OUTPATH=${MAINPATH}/nudging/${DATA_SET}
TEMPLATES=${MAINPATH}/templates/
TMPPATH=${MAINPATH}/tmp/
CDO='cdo'
SCRIPTPATH=`pwd`
POOL=/pool/data/ERA5/E5/ml/an/1H/

mkdir -p $INPATH $OUTPATH $TEMPLATES $TMPPATH
DATASOURCE="POOL"




# submit command
# if you don't want to launch via sbatch and run interactively - useful for testing
#export SUBMIT='bash'
export SUBMIT='sbatch -p interactive -c 8 --mem-per-cpu=5300M --time=07:00:00 -A ba1264'

#load required environment
export LOAD_ENV='module swap cdo/2.0.6-gcc-11.2.0'

## USER EDIT REQUIRED ##
## options for create_template script only
INPATH_TEMPLATE=/work/ab0246/a270092/input/oifs-43r3/${RES}/
EXPID='aack'
#this is for FESOM only
FESOM_MESH="CORE2"

