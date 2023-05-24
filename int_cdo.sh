#!/bin/ksh
#
# Feb 2011:     Original implementation of the CDO command sequence for
#               preparing nudging files for ECHAM
#               S. Rast, A. Voigt, U. Schulzweida
#
# May 2021:     Adapting the CDO sequence for 
#               preparing nudging files for OIFS
#               M. Athanase
# Mar 2023:     update for ECMWF HPC2020
#               E. Tourigny
######################################################################## 

set -xuve
#set -ue

CDO=$1
TEMPLATE=$2
NDGTAG=$3
SCRIPTPATH=$4
RES=$5
ERAMONTHDIR=$6
OUTPATH=$7
TMPPATH=$8
# Interpolation and format transformation of nudging data using CDO
#
# Definition of default output file names:
# (output files should not yet exist)
#SPOUT=${FBASENAME}.nc
#SPOUT=${FBASENAME}

rm -rf $TMPPATH
mkdir -p $TMPPATH
cd $TMPPATH

mkdir -p ${OUTPATH}/gg
mkdir -p ${OUTPATH}/sh

set +u

########################################################################
# Interpolation with CDO command sequence:
rm -f interpolation_$$.sh
cat >> interpolation_$$.sh <<EOF
#!/bin/bash

${LOAD_ENV}
NDGTAG=\${NDGTAG}

set -xuve
#set -ue

########################################################################
# interpolation of given data for nudging. New land sea mask and
# orography is taken into account
# $SPDATA: spectral data, GRIB-codes 129,152,130,138,155
# $GPDATA: grid point data: GRIB-code 133
# $TEMPLATE: template file containing new land sea mask, orography and an 
#  arbitrary 3d-spectral field
# $SPOUT: spectral data output file 
########################################################################
# 1. Start monthly loop: execute interpolation for each time step 
# separately, serially.
#
########################################################################
for f in \`ls ${ERAMONTHDIR}/????????????.sp\`;
do
  FBASENAME=\`echo \$f | awk -F "." '{print \$1}'\`
########################################
# To fix: read passed-in tag prefix
#  TSTAMP=\`echo \${FBASENAME#\${NDGTAG}}\`
#  TSTAMP=\${FBASENAME#era5_}
  TSTAMP=\`basename \${FBASENAME#\${NDGTAG}}\`
  
  echo 'TSTAMP='\$TSTAMP

  SPOUTGP=\`echo 'rlxmlgg'\${TSTAMP}\`
  SPOUTSP=\`echo 'rlxmlsh'\${TSTAMP}\`
  GPDATA=\`echo \${FBASENAME}'.gp'\`
  SPDATA=\`echo \${FBASENAME}'.sp'\`

  echo 'SPDATA='\$SPDATA

  if [ -e ${OUTPATH}/sh/\$SPOUTSP ]; then
  echo \$SPOUTSP ' already exists'
  exit 1
  fi
########################################################################
# 2. Preparation of meteorological input data of the 
# ECMWF analysis
# note: i. the gridpoint data is transformed to full 
#	   Gaussian grid with cdo option -R
#      ii. relative vorticity and divergence are transformed 
#          to horizontal winds to be consistent with INTERA.
#          Since the spectral resolution may be different from the 
#          gridpoint resolution, the spectral resolution is adjusted.
#     iii. cdo remapeta demands grid point variables, 
#          therefore the spectral data is converted to 
#          gridpoint space
#      iv. input data is merged into one file
########################################################################
  set -x
  TRUNCATION=\`${CDO} sinfo \$GPDATA |grep nlat\`
  TRUNCATION=\`echo \$TRUNCATION | awk '{ print \$6 }'\`
  TRUNCATION=\${TRUNCATION#nlat=}
  TRUNCATION=\$(( 2 * TRUNCATION - 1 ))
  TRUNCATION=\$(( TRUNCATION / 3 ))
  echo 'TRUNCATION='\$TRUNCATION
  ${CDO} -b 64 setgridtype,regular \$GPDATA temp1_$$
  ${CDO} -b 64 -P 8 sp2gp -dv2uv -sp2sp,\${TRUNCATION} \$SPDATA temp2_$$
  ${CDO} -b 64 merge temp1_$$ temp2_$$ rawdata_$$
  rm -f temp1_$$ temp2_$$
#########################################################################
#
# 3. New orography and vct coefficients
#  i. Extract vct coefficients from template
# ii. Interpolate orography of OIFS horizontal resolution to 
#     higher horizontal resolution of input data
#     note: to be consistent with INTERA, this is done 
#       in spectral space by filling up the spectral 
#       coefficients with zeros or cutting them
#
# vct_dat: contains A and B coefficients of target vertical grid
########################################################################
  ${CDO} -b 64 vct ${TEMPLATE} > vct_dat
########################################################################
# template.oifsT...L.., code 129: orography of target grid
# interpolate new orography to higher horizontal resolution
# extract spectral resolution first
########################################################################
  ${CDO} -b 64 -P 8 sp2gp -sp2sp,\${TRUNCATION} -selname,var129 ${TEMPLATE} oro_$$
########################################################################
#
# 4. Do vertical interpolation using cdo remapeta
#
########################################################################
  ${CDO} -b 64 -P 8 remapeta,vct_dat,oro_$$ rawdata_$$ temp_$$
  rm -f vct_dat oro_$$ rawdata_$$
########################################################################
# Attention: this gives warning messages of the following type
# cdo remapeta (Warning): Output temperature at level 8 out of range (min=213.646 max=323.73)!
# cdo remapeta (Warning): Output humidity at level 49 out of range (min=-4.45857e-20 max=0.0155792)!
#
# 5. Postprocess the result of cdo remapeta:
# - delete specific humidity
# - calculate divergence and relative vorticity 
#   from horizontal winds
# - transformation to spectral space
# - truncate spectral coefficient to TXX
#
########################################################################
  NEWTRUNCATION=\`${CDO} sinfo $TEMPLATE |grep nsp\`
  NEWTRUNCATION=\`echo \$NEWTRUNCATION | awk '{ print \$7 }'\`
  NEWTRUNCATION=\${NEWTRUNCATION#T}
  echo 'NEWTRUNCATION='\$NEWTRUNCATION
  ${CDO} -b 64 -selname,var133 ${TEMPLATE} reducedgrid_$$
#  ${CDO} -b 64 -P 8 --eccodes -f grb2 -remapbil,reducedgrid_$$ -chparam,0.1.0,133.128 -selname,q temp_$$ ${OUTPATH}/gg/\${SPOUTGP}
  ${CDO} -b 64 -P 8 --eccodes -f grb -remapbil,reducedgrid_$$ -chparam,0.1.0,133.128 -selname,q temp_$$ ${OUTPATH}/gg/\${SPOUTGP}

  ${CDO} -b 64 -P 8 -f grb2 gp2sp -uv2dv -delname,q temp_$$ \${SPOUTSP}
  ${CDO} -b 64 -P 8 -f grb2 sp2sp,\${NEWTRUNCATION} -selcode,138,155 \${SPOUTSP} \${SPOUTSP}_codes
  ${CDO} -b 64 -P 8 -f grb2 sp2sp,\${NEWTRUNCATION} -selname,z,t,param25.3.0 \${SPOUTSP} \${SPOUTSP}_names
  rm -f temp_$$ \${SPOUTSP} reducedgrid_$$
  ${CDO} -b 64 -f grb2 merge \${SPOUTSP}_codes \${SPOUTSP}_names temp_$$
#  ${CDO} -a -b 64 --eccodes -f grb2 copy -chparam,4.3.0,129.128 -chparam,25.3.0,152.128 -chparam,0.0.0,130.128 -chname,var155,sd -chname,param25.3.0,lsp -chname,var138,svo temp_$$ ${OUTPATH}/sh/\${SPOUTSP}
  ${CDO} -a -b 64 --eccodes -f grb copy -chparam,4.3.0,129.128 -chparam,25.3.0,152.128 -chparam,0.0.0,130.128 -chname,var155,sd -chname,param25.3.0,lsp -chname,var138,svo temp_$$ ${OUTPATH}/sh/\${SPOUTSP}

  rm -f temp_$$ \${SPOUTSP}_codes \${SPOUTSP}_names
done
EOF
${SUBMIT} interpolation_$$.sh


