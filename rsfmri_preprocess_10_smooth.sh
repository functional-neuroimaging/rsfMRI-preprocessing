#!/bin/bash

# This script smooths the ts with a gaussian kernel of 600um.
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2019)
# -----------------------------------------------------------

numjobs=7

function smooth {

    ts=$1
    subject=$(basename $ts _filtered.nii.gz)
    
    kernel=6
    brainmask=chd8_functional_template_mask.nii.gz # edit this

    3dBlurInMask \
        -input $ts \
        -prefix ${subject}_smoothed.nii.gz \
        -mask $brainmask \
        -FWHM $kernel
        
    }
export -f smooth

# Main code starts here
echo *_filtered.nii.gz | tr " " "\n" > subject_list.txt

parallel \
    -j $numjobs \
    smooth {} $kernel $brainmask \
    < subject_list.txt
