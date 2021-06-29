#!/bin/bash

# This script reorganises the images so that you will have a folder 
# for each preprocessing step.
#
# Run this script in the folder containing extracted files to remove 
# all the subfolders. That is the $outputdir of the previous script.
#
# It is very harmful to run this script outside that folder because 
# it will destroy the entire folder hierarchy, then please pay attention.
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2019)
# -----------------------------------------------------------


find . -mindepth 2 -type f -print -exec mv {} . \;
find -mindepth 1 -maxdepth 1 -type d -exec rm -r {} \;
