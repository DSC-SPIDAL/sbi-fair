#!/bin/bash
wget https://github.com/YudongYao/AutoPhaseNN/raw/3375cf98206a83f329faaf4c74eed924f3f4a2fe/TF2/prep_upsamp_3Ddata.ipynb
jupyter-nbconvert --config 'empty_nonexistent_dummy.py' --to python --output-dir . prep_upsamp_3Ddata.ipynb
patch prep_upsamp_3Ddata.py /install/prep_upsamp_3Ddata.patch
