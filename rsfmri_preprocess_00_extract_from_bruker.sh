#!/bin/bash

# This script converts bruker timeseries to nifti format.
#
# You are strongly advised not to work directly on the disk
# of the scanner, where original data are stored but instead
# you may want to copy and paste data on your local disk.
#
# Use this script in the "datadir" folder containing all 
# bruker folders (one per mouse) copied from the scanner.
#
# Remember that this script also increases the voxel size by 
# a factor of 10 to artificially make the mouse brain comparable 
# to human brain in size and then allows you to use MRI tools 
# implemented for humans.
#
# The mandatory format of runs.txt is the following, where the 
# first field is the name of the bruker folder (i.e. the mouse ID), 
# the second field is the group name (e.g. genotype, sex, ...) 
# and the third is the folder number and name of the MRI sequence 
# (e.g. BOLD,..). The folder number is reported on the excel file 
# of the study. following is an example of runs.txt:
#
# ag190305b.ux1 suffix:WT 9:BOLD
# ag190306c.uc2 suffix:KO 7:T2W
# ...
#
# The whole preprocessing pipeline heavely relies on GNU parallel, 
# AFNI, FSL and Matlab then make sure you have all this tools 
# installed on your workstation/server. 
#
# Also, this code comes with the folders "bruker2nifti", then remember:
# - to edit this code with the path_to/bruker2nifti/dependencies/NIfTI_20140122/
# - to add pvconv.pl to .bashrc profile if needed.
#
# If this is the first time you use pvconv.pl in your workstation, 
# you may want to read the README file contained in the pvconv folder.
# In this case, you may also be required to install Math-Matrix and 
# Getopt-ArgvFile by typing the following (or similar) in the terminal:
#   sudo apt-get install cpanminus
#   sudo cpanm Math::Matrix
#   sudo cpanm Getopt::ArgvFile
# and make:
#   perl Makefile.PL
#   make
#   make install
#
# In case you are carrying out analysis of optofMRI timeseries and 
# you get a "Arg scalar value error", you may want to comment line 
# 327 and 328 of pvconv.pl.
#
# I tried to write everything as clear as possible, then please read 
# the notes you will find at the beginning of each script that will 
# explain to you what you are doing :)
#
# You can run most of the scripts in parallel, default number of jobs 
# is jobs=7, edit this according to your workstation/server capabilities.
#
# Paravision 6 will output files with very long and redundant names, please
# manually edit them in a way that looks like the following hence you will
# be able to trace back the ID of the mouse: ag190305b, ag190306c, ...  
#
# Now relax and enjoy resting state functional connectivity!!
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2019)
# -----------------------------------------------------------



datadir=/path/to/folder/containing/raw/folders/copied/from/scanner/ # edit this
scanfile=/path/to/list/of/sequences/to/be/extracted/runs.txt # edit this
outputdir=/output/folder/where/sequences/will/be/extracted/ # edit this

jobs=7

function session_name {
    rev | cut -c 5- | rev
}
export -f session_name

function process_pvconv_output {
    origname=$1
    finalname=$2

    matlab -nodesktop -nosplash -nodisplay \
        -r "addpath(genpath('/home/imaging/config/scripts/restingstate_scripts/preprocessing_marco/bruker2nifti/dependencies/NIfTI_20140122/')); mat_into_hdr('${origname}.mat'); exit" # edit this

    3dcalc \
        -a ${origname}.hdr \
        -expr a \
        -prefix ${origname}.nii.gz

    3dresample \
        -orient RPI \
        -inset ${origname}.nii.gz \
        -prefix ${finalname}.nii.gz

    3drefit \
        -xyzscale 10 \
        ${finalname}.nii.gz

    rm ${origname}*
}
export -f process_pvconv_output

function convert_run_from_bruker {
    sessiondir=$1
    run=$2
    suffix=$3

    runnumber=$(echo $run | tr ':' ' ' | awk '{print $1}')
    runsuffix=$(echo $run | tr ':' ' ' | awk '{print $2}')

    name=$(basename $sessiondir | session_name)

    if [ ! -z "$suffix" ]
    then
        fname=${name}_${suffix}_${runnumber}_${runsuffix}
    else
        fname=${name}_${runnumber}_${runsuffix}
    fi

    mkdir -p $name/${runnumber}_${runsuffix} && cd $name/${runnumber}_${runsuffix}
    
    pvconv.pl \
        -series $runnumber \
        -outfile ${fname}_orig \
        $sessiondir 
   
    if [ $(ls . | wc -l) -eq 4 ]
    then 
        process_pvconv_output \
            ${fname}_orig \
            ${fname}
    else
        for i in {0..7}
        do
            process_pvconv_output \
                ${fname}_orig_acq${i} \
                ${fname}_acq${i}
        done
    fi
 
    cd ../..
}
export -f convert_run_from_bruker

function process_session {
    sessionstring="$1"
    datadir=$2

    session=$(echo $sessionstring | cut -f1 -d' ')
    runs=$(echo $sessionstring | cut -f3 -d' ')

    suffix=$(echo $sessionstring | cut -f2 -d' ' | tr ',' '\n' | \
        while read -r option
        do
            if [[ "$option" == suffix* ]]
            then
                echo $option | cut -f2 -d':'
                break
            fi
        done)

    name=$(echo $session | session_name)
    
    if [ ! -d "$name" ]
    then
        mkdir $name
    fi

    echo $runs | tr ',' '\n' | \
        while read -r run
        do
            convert_run_from_bruker $datadir/$session $run $suffix
        done &> ${name}/log.txt
}
export -f process_session

# Main starts here
if [ ! -d $outputdir ]
then
    mkdir $outputdir
fi
cd $outputdir
parallel \
    -j $jobs \
    process_session "{}" $datadir \
    < $scanfile
