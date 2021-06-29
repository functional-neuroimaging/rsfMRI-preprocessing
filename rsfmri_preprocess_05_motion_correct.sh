#!/bin/bash

# This script carries out motion correction by using mcflirt. 
# Here we use the mean volume as reference, every other parameter
# (e.g. cost function) is default.
#
# The main outputs of this script are the realligned ts and 
# the 6 motion traces (3 rotations + 3 traslations). You will use these
# motion traces to carry out nuisance regression and for the carpet plot.
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2019)
# -----------------------------------------------------------



numjobs=7

function motion_correction {
    
    ts=$1
    subject=$(basename $ts _despike.nii.gz)

    mcflirt \
        -in ${ts} \
        -meanvol \
	-plots \
	-report \
	-out ${subject}_mcf

    cp ${subject}_mcf.par ${subject}_mcf.txt

    }
export -f motion_correction

# main code starts here
echo ag*_despike.nii.gz | tr " " "\n" > subject_list.txt

parallel \
    -j $numjobs \
    motion_correction {} \
    < subject_list.txt 


