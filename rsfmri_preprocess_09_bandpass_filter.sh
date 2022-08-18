#!/bin/bash

# This script performs bandpass filtering to the ts (range = 0.01 - 0.1 Hz).
# In case the TR is incorrect in the .hdr, the TR set in 3dBandpass will overwrite.
#
# The script also calculates a version of filtered ts plus the mean of the ts.
# This comes in handy for the quality check with the carpet plot. 
# Do not use that for preprocessing.
#
# Remember to edit the TR and the brainmask
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2019)
# -----------------------------------------------------------


numjobs=7

function bandpass_filter {

    ts=$1
    subject=$(basename $ts _regressed.nii.gz) 
    
    tr=1.2 # edit this
    bandpass_from=0.01 # edit this to change filter lower limit
    bandpass_to=0.1 # edit this to change filter upper limit
    
    brainmask=path/to/chd8_functional_template_mask.nii.gz # edit this

    # this filters ts
    3dBandpass \
        -dt $tr \
        -mask $brainmask \
        -prefix ${subject}_filtered.nii.gz \
        ${bandpass_from} ${bandpass_to} \
        $ts 

    # this adds the mean to filtered ts, useful for carpet plot 
    3dTstat \
        -mean \
        -prefix ${subject}_mean_before_bp.nii.gz \
        $ts

    fslmaths \
	${subject}_filtered.nii.gz \
	-add ${subject}_mean_before_bp.nii.gz \
	${subject}_filtered_with_mean.nii.gz
 
    rm ${subject}_mean_before_bp.nii.gz 

}
export -f bandpass_filter

# main code starts here
echo ag*_regressed.nii.gz | tr " " "\n" > subject_list.txt

parallel \
    -j $numjobs \
    bandpass_filter {} \
    < subject_list.txt
