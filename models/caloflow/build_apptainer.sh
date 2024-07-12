#!/bin/bash
rm -r helpers
cp -a ../../tools/helpers .
../../tools/helpers/replace_content.py Apptainer.template.def install_section recipes/000_install.scif apps_section recipes/001_apps.scif > Apptainer.def
apptainer build caloflow.sif Apptainer.def

