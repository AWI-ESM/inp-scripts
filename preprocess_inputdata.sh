#!/bin/sh 
#
# Oct 2021: Implementation of the command sequence for 
#  	    the preparation of input ERA5 data required
#	    to produce nudging files
#	    M. Athanase, H. Goessling
#
# Usage and subroutines description in README
########################################################
NDGTAG=$1       # TAG of nudging data, e.g. era5_ or analogous
BYEAR=$2        # First year to preprocess
EYEAR=$3        # Year at which the preprocessing ends (!excluded!)

# path with the CDO module:
CDO='/sw/spack-levante/mambaforge-4.11.0-0-Linux-x86_64-sobz6z/bin/cdo'
# path to script folder:
SCRIPTPATH=/home/a/a270170/SCRIPTS/04_NUDGING/OPEN_nudging_cdo/
# path for the raw reanalysis data:
POOL=/pool/data/ERA5/ml00_1H/
# path for output of the monthly reanalysis data:
OUTPATH=/scratch/a/a270170/nudging/input_files/${NDGTAG}

sbatch ${SCRIPTPATH}/preprocess_inputdata_year.sh ${CDO} ${SCRIPTPATH} ${POOL} ${OUTPATH} ${NDGTAG} ${BYEAR} ${EYEAR}

