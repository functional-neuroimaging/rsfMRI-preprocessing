#!/bin/bash

# This script performs nuisance regression by regressing out the 
# six motion parameters and the mean ventricular BOLD signal. 
# 
# Please do not manually draw a personal ventricle mask, use instead 
# the ventricle mask called chd8_functional_template_ventricles_ag.nii.gz
#
# We do not perform global signal regression.
#
# To use this code, also remember to copy and paste the 
# motion traces in the folder containing the registered ts.
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2019)
# -----------------------------------------------------------


numjobs=7

function regress_nuisance_subject {

    ts=$1
    subject=$(basename $ts _registered.nii.gz) # registered ts
    mcp=${subject}_mcf.txt # motion traces

    ventriclemask=path/to/chd8_functional_template_ventricles_ag.nii.gz # edit this, this is ventricle mask drawn on chd8 template
    brainmask=path/to/chd8_functional_template_mask.nii.gz # edit this, this is the chd8 brainmask

    # extract mean signal in the ventricular mask
    fslmeants \
        -i $ts \
        -m $ventriclemask \
        -o ${subject}_vs.txt

    # merge motion traces and ventricles ts in one txt file
    paste $mcp ${subject}_vs.txt > ${subject}_to_regress.txt
    Text2Vest ${subject}_to_regress.txt ${subject}_to_regress.mat

    # nuisance regression. 
    fsl_regfilt \
	-i $ts \
	-d ${subject}_to_regress.mat \
	-f "1,2,3,4,5,6,7" \
	-m $brainmask \
        -o ${subject}_regressed.nii.gz 

    # this cleans the output
    rm ${subject}_vs.txt
    rm ${subject}_to_regress.txt
    rm ${subject}_to_regress.mat
       
    }
export -f regress_nuisance_subject

# main code starts here
echo ag*_registered.nii.gz | tr " " "\n" > subject_list.txt # edit this, registered ts

parallel \
    -j $numjobs \
    regress_nuisance_subject {} \
    < subject_list.txt

