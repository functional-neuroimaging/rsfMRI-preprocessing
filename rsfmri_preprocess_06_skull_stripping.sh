#!/bin/bash

# This script performs skull-stripping i.e. removes extra-brain tissues
#
# This is inspired by Granjean collaborative study that in turn
# has been inspired from FSL pipeline for skull stripping
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2019)
# -----------------------------------------------------------


numjobs=7

function brain_mask_subject {
    
    ts=$1
    subject=$(basename $ts _mcf.nii.gz)    
    radius=50

    fslmaths \
	    $ts \
	    -Tmean \
	    ${subject}_tmean.nii.gz 

    T=$(fslstats ${subject}_tmean.nii.gz -p 98)
    z=$(echo "$T / 10" | bc -l)

    fslmaths \
	    ${subject}_tmean.nii.gz \
	    -thr ${z} \
	    ${subject}_tmean_thr.nii.gz

    fast \
	--nopve \
	-B \
	${subject}_tmean_thr.nii.gz
  
    bet \
	${subject}_tmean_thr_restore.nii.gz \
	${subject}_tmean_thr_restore_brain.nii.gz \
	-r $radius \
	-R \
	-m

    mv  \
	${subject}_tmean_thr_restore_brain_mask.nii.gz \
	${subject}_mask.nii.gz
    
    fslmaths \
	${subject}_tmean.nii.gz \
	-mul ${subject}_mask.nii.gz \
	${subject}_mean_skull_stripped.nii.gz

    fslmaths \
	$ts \
	-mul ${subject}_mask.nii.gz \
	${subject}_skull_stripped.nii.gz

    rm ${subject}_tmean.nii.gz
    rm ${subject}_tmean_thr.nii.gz
    rm ${subject}_tmean_thr_restore.nii.gz
    rm ${subject}_tmean_thr_restore_brain.nii.gz
    rm ${subject}_tmean_thr_seg.nii.gz

    
    }
export -f brain_mask_subject

# main code starts here
echo *_mcf.nii.gz | tr " " "\n" > list.txt

parallel \
    -j $numjobs \
    brain_mask_subject {} \
    < list.txt
