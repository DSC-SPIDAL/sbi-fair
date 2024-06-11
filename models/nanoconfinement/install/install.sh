#!/bin/bash
mkdir nanoconfinement-md
cd nanoconfinement-md
# Doing that instead of clone to limit the fetch to relevent commit
git init; git remote add origin https://github.com/softmaterialslab/nanoconfinement-md
git fetch --depth 1 --filter=blob:limit=10M origin 7c6aa48d2260da15b243702747ebe1c806c5eee9
git checkout FETCH_HEAD
cd ..

## Pick the relevant part only
mv nanoconfinement-md/python/surrogate_samplesize/* .
rm -r nanoconfinement-md
####

#### Convert and patch
# Convert to script from notebook
jupyter-nbconvert --config 'empty_nonexistent_dummy.py' --to python --output-dir . Ions_surrogate_training_excluderandom.ipynb
# 
# Patching sources
cp Ions_surrogate_training_excluderandom.py train.py
cp Ions_surrogate_training_excluderandom.py evaluate.py
patch train.py train.patch && chmod +x train.py
patch evaluate.py evaluate.patch && chmod +x evaluate.py

# Make the entry scripts available
pwd
mkdir -p ${SCIF_APPROOT}/bin
mkdir -p ${SCIF_APPDATA}
cp train.py ${SCIF_APPROOT}/bin
cp evaluate.py ${SCIF_APPROOT}/bin
cp all_data_4050/scaler_new.pkl ${SCIF_APPDATA}

