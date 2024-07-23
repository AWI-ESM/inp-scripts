#!/bin/bash
# Jul 2022: Creating steering script
#           J. Streffing
# Mar 2023: update for ECMWF HPC2020
#           E. Tourigny
# Jul 2024: Split into config and main scripts
#           J. Streffing

set -xuve
#set -ue

# configuration options for this run: dataset, resolution 
# and dates (first/last year and first/last month)
DATA_SET='era5_'
RES='TL159L91'
BYEAR=2010
EYEAR=2010
BMONTH=01
EMONTH=02

# main configuration options, adapt to your user/environment
INPATH=/scratch/c3et/nudging/data/${DATA_SET}raw
OUTPATH=/scratch/c3et/nudging/data/${DATA_SET}
#POOL=/perm/c3et/nudging/data/${DATA_SET}raw #unused at ecmwf
TEMPLATES=/perm/c3et/nudging/data/templates
TMPPATH=/scratch/c3et/nudging/tmp/
CDO='cdo'
SCRIPTPATH=`pwd`

# submit command
# if you don't want to launch via sbatch and run interactively - useful for testing
#export SUBMIT='bash'
#on hpc-login
#export SUBMIT='sbatch -q nf -c 8 --mem-per-cpu=5300M -A spnlpete'
# on ecs-login
export SUBMIT='sbatch -q ef -c 8 --mem=16GB -A spnlpete'

#load required environment
export LOAD_ENV='module load cdo/2.0.6'

# options for create_template script only
#this is for ECE4
INPATH_TEMPLATE=/hpcperm/c3et/models/ecearth/v4-trunk/oifs/${RES}/19900101
EXPID='ECE4'
#this is for ECE3
#INPATH_TEMPLATE=/hpcperm/c3et/ece3data/ifs/${RES}/19900101
#EXPID='ECE3'
#this is for FESOM only
FESOM_MESH="-"

