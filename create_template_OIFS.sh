#!/bin/ksh
#
# Feb 2011: Implementation of the command sequence for 
#	    the preparation of template files for ECHAM
#	    S. Rast, A. Voigt, U. Schulzweida
#
# Oct 2021: Adaptation of the command sequence for the
#           preparation of template files for OpenIFS
#           M. Athanase, H. Goessling
#
# Jul 2022: Consolidation into single script
#           J. Streffing
# Usage and subroutines description in README
########################################################
RES=$1 		# Requested OpenIFS resolution e.g. TCO159L91
EXPID=$2	# Corresponding experiment ID e.g. h9wu
FESOM_MESH=$3   # Part of file names that signifies IFS files modified for FESOM
INPATH=$4       # Path to your ICM* OpenIFS initial state files
OUTPATH=$5      # Path for output of template files
CDO=$6          # Path to specific CDO binary

mkdir -p $OUTPATH

rm -f tmp1$$ tmp2$$ tmp3$$ tmp4$$
${CDO} seltimestep,1 ${INPATH}/ICMGG${EXPID}INIT_${FESOM_MESH} tmp1$$
${CDO} seltimestep,1 ${INPATH}/ICMGG${EXPID}INIUA tmp1a$$
${CDO} seltimestep,1 ${INPATH}/ICMSH${EXPID}INIT tmp2$$
${CDO} --eccodes -f grb2 -selcode,172 -setgridtype,regular tmp1$$ tmp3a$$
${CDO} -f grb2 -chparam,0.1.0,133.128 -selname,q tmp1a$$ tmp3b$$
${CDO} -f grb2 -selname,z tmp2$$ tmp4a$$
${CDO} -f grb2 -selname,t tmp2$$ tmp4b$$
${CDO} merge tmp4a$$ tmp4b$$ tmp3a$$ tmp3b$$ tmp_$$
${CDO} -chparam,0.0.0,130.128 -chparam,4.3,129.138 tmp_$$ ${OUTPATH}/template.oifs${RES}
rm -f tmp*$$ 

if [ -f "${OUTPATH}/template.oifs${RES}" ]; then
    echo "Template file  template.oifs${RES}  was created"
else 
    echo "Creation of template file failed"
fi



