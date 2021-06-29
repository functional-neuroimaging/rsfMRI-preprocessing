#!/bin/bash

# This script realligns skull stripped ts to a skull stripped 
# BOLD functional template (i.e. chd8_template).
#
# You will find the registered ts in the folder called "registered".
#
# As mis-registration may occur, please check all the output ts one 
# by one. The fastest way to do so is to concatenate the registered 
# means and check them visually with FSL viewer.
#
# This script uses a lot of CPU then set numjobs to max 4 or so.  
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2019)
# -----------------------------------------------------------


numjobs=4 # edit this

function register_ts {

	template=chd8_functional_template_sk.nii.gz # edit this
	ts=$1
	subject=$(basename $ts _skull_stripped.nii.gz)

	3dTstat \
		-mean \
		-prefix ${subject}_mean.nii.gz \
		$ts

	antsRegistration \
			-d 3 \
			-r [${template},${subject}_mean.nii.gz,1] \
			-m CC[${template},${subject}_mean.nii.gz,1,2] \
			-t Affine[0.25] \
			-c 100x100x30 \
			-s 5x3x0 \
			-f 5x3x1 \
			-m CC[${template},${subject}_mean.nii.gz,1,2] \
			-t SyN[0.15,5,1] \
			-c 100x100x30 \
			-s 5x3x0 \
			-f 5x3x1 \
			-o ${subject}_

	antsApplyTransforms \
			-d 3 \
		    	-e 3 \
		    	-i $ts \
		    	-o ${subject}_registered.nii.gz \
		    	-r ${template} \
		    	-t ${subject}_1Warp.nii.gz \
		    	-t ${subject}_0GenericAffine.mat

	3dTstat \
		-mean \
		-prefix ${subject}_registered_mean.nii.gz \
		${subject}_registered.nii.gz

	mv ${subject}_0GenericAffine.mat affines
	mv ${subject}_1InverseWarp.nii.gz inverse_warps
	mv ${subject}_1Warp.nii.gz warps
	mv ${subject}_registered.nii.gz registered
	mv ${subject}_registered_mean.nii.gz registered_means

	rm ${subject}_mean.nii.gz

}
export -f register_ts

# main code starts here
mkdir affines
mkdir inverse_warps
mkdir warps
mkdir registered 
mkdir registered_means 

echo ag*_skull_stripped.nii.gz | tr " " "\n" > subject_list.txt

parallel \
    -j $numjobs \
    register_ts {} \
    < subject_list.txt


