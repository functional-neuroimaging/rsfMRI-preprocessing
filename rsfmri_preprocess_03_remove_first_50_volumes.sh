#!bin/bash

# This script removes the first 50 volumes from timeseries 
# Signal from first 50 volumes is removed because our scanner
# is subject to thermal noise during the first minute of acquisition.
#
# If you want to use this script for other purposes, remember that
# 3dTcat counts from 0.
#
# Please also change TR of this script in two places if needed (here is 1.2).
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2019)
# -----------------------------------------------------------


for ts in *_1.2.nii.gz ; do # edit this

	subject=${ts%_1.2.nii.gz} # edit this

	3dTcat -prefix ${subject}_chopped.nii.gz ${ts}'[50..$]'

done



