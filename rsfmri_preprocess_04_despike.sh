#!/bin/bash

# This script despikes the ts. 
#
# https://www.sciencedirect.com/science/article/pii/S1053811914001578#f0090
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2019)
# -----------------------------------------------------------

numjobs=7

function despike_subject {

    ts=$1
    subject=$(basename $ts _chopped.nii.gz)
    
    3dDespike \
        -nomask \
        -prefix ${subject}_despike.nii.gz \
        $ts \
        &> ${subject}_log_despiking.txt	
	
}
export -f despike_subject

# main code starts here
echo ag*_chopped.nii.gz | tr " " "\n" > subject_list.txt
parallel \
    -j $numjobs \
    despike_subject {} \
    < subject_list.txt
