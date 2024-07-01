#!/bin/bash
export FILE_LIST=/input/dataset
export OUTPUT_DIR=/output/
export INPUT_DIR=/output/ # The same where we download
# In this case the dataset is the list of files, need to be downloaded
# Download only if files are newer/changed
wget -N -i ${FILE_LIST} -P ${INPUT_DIR}
python /install/prep_upsamp_3Ddata.py