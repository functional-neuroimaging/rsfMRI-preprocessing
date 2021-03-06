# rsfmri_preprocessing

Guide for preprocessing rsfMRI data and quality check. 

David Sastre 

 

This guide is based on the Marco Pagani’s pre-processing scrips (2018) 

Scripts are written in bash. 

Each script can be opened with a text editor, the lines that must be changed (if any) are clearly identified with the comment #Edit this (on blue). 

Edition needed is typically the directory for templates, or file names. 

  

Considerations before starting: 

The first step implies copying all the files to be reconstructed from the NAS server to the working station. NEVER run any script/console command on the NAS server, to avoid deletion or corruption of files.  

Be careful with the names of the files. Consider the order of your analysis, i.e., “gender_treatment_age”. For later analysis (for instance, long range connectivity) the name must be identical and respect the order. If not, names need to be changed, or the scripts need to be adapted by using unix sidecards. Characters and file names in Unix have some rules. As a principle, NEVER use space (use “_” instead), be aware of misspellings (scripts are case sensitive as well), and avoid weird characters that can create conflicts with the bash scripts (~,?,&, etc). 

Keep the folder structure as clean as possible.  

The input of one given step is usually the output of the next one. Always copy the previous step to a new folder, rename it (00_..,01_..,02_..., etc), and run the script inside. Afterwards, one can delete the older files (from step X-1, that were the input for this given step). Keeping all the intermediate steps is advisable. If one encounters an error, o commits a mistake; it is easier to go back to X-1 step than restarting from zero.  

The files needed (scripts and templates) are located in the One Drive, inside the folder Procedures>resting_state_mri>preprocessing. There are different versions, chose the last one. 

 

Marco Pagani wrote solid and easy to follow simple scripts breaking down each step of the preprocessing. Each script has a comprehensive description of what it does and what it needs to be edited before the actual code, read it. Always check the output of the terminal, if there is an error is typically prompted there. 

All the scripts have an index (00, 01, 02…). This is the order of the steps to be taken. This is the standard pipeline, some extra steps might be needed for your specific requirements. 

Step by step 

    Copy files from NAS to your folder inside the working station, create one folder for this. 

Before moving to the next step, inspect that all the files have been copied, with the required subfolders (Linux fails) 

 

    Extract the timeseries and convert it from the bruker format to the nifty. Script 00_extract_from_bruker. One needs to copy the directory (where the files to reconstruct are located), also the output directory (folder that will contained the nifty, typically 00_originals). One needs to generate also the “scanfile”, a text file containing a list of all the subjects to be reconstructed following this order: 

     ag150305b.ux1 suffix:WT 9:BOLD     

    name suffix:XX name_of_folder_to_reconstruc:name of the folder 

     Suffix is decided by you, as mentioned above, think carefully the names, to avoid later renaming. 

     This info is in the excel folder generated by Alberto while scanning 

     After this has been done, it is always advisable to manually check all of them using FSLView, for two reasons: 

     To be sure that everything is there and has been properly reconstructed. 

     To notice movement, weird artifacts, or similar things. 

 

    01_delete_folders. Run this script in the folder containing the nifty (.nii) files. It will remove unnecessary folders and restructure everything. 

 

    Change TR. Not all fMRI acquisitions have the same TR (look for yours, alberto’s excel sheet). The edition needed is the TR. It will add this number to the name of the file. 

 

 

    03_remove_first… this script will eliminate the first 50 volumes of the timeseries. Remember that the script works for folders with a TR of 1.2. If you used a different one (therefore, the folder has a different name), change it in the script (replace 1.2.nii.gz on line 12 for whatever number yours is). The output will be now …_chopped.nii.gz 

 

    04_despike, for the despiking. There will an output called subject_list, needed for the next step. 

 

 

    05_motion_corretc. This will generate a few files, with the extensions .par and .text. You will need them for later. 

 

    06_Skull_stripping. The input for this script is the mfc.nii.gz scans from the motion correction, and the subject list from the despiking. 

 

    09_registration. For the registration, we need to use a template. On the script, there will be an #edit this. Here we need to add the path to the cdh8_functional_template_sk.nii.gz. also, we need to have within the folder the subject list generated from the skull stripping. The script is going to output as well a few directories. 

 

    10_regress_nuisance. To the files from the previous folder, one also needs to copy and paste all the mfc.txt from the motion correction. The script also needs the directory for 2 masks: in the input variable ventriclemask the directory needed is for the chd8_functional_template_ventricles.nii.gz file; and for the input variable brainmask, the chd8_functional_template_mask.nii.gz. 

 

    11_bandpass_filter needs as an input the directory of the mask chd8_functional_template_mask.nii.gz. Also, pay caution on the values for the ts and the bandpass range. 

 

    12_smooth. This is the final step, where the preprocessed timeseries are going to be smoothed. One needs to add the directory for the file chd8_functional_template_mask.nii.gz in the input variable brainmask. 

Congratulations, you are done!! Your smoothed files are the final files that you will use for your analysis. Keep them and treat them with the proper care. By now is always good to do another visual inspection to see if everything looks normal and that there are no files corrupted. The final timeseries, already preprocessed, will have the following name: ag_whatevernameyoudecided_smoothed.nii.gz. 
