#!bin/bash

# This script writes the right TR in the header of the ts.
#
# This step is needed because pvconv.pl outputs ts with 
# a wrong TR (TR=1000).
#
# TR has to be specified is seconds. In this code, TR is 1.2 sec.
# Edit this script (in two places) with the TR of your ts.  
#
# This step is not strictly necessary since 3dBandpass overwrites 
# the TR value of the header, however if you use this script the 
# TR value of the header will be ok forever. 
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2019)
# -----------------------------------------------------------


tr=1.2 # edit this

for ts in ag*.nii.gz ; do

	fslsplit $ts ${ts%.nii.gz}_vol -t 

	fslmerge -tr ${ts%.nii.gz}_1.2.nii.gz ${ts%.nii.gz}_vol* $tr # edit this

	rm ${ts%.nii.gz}_vol*

done
