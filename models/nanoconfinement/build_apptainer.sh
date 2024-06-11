#!/bin/bash
../../tools/helpers/replace_content.py Apptainer.template.def install_section recipes/000_install.scif apps_section recipes/001_apps.scif > Apptainer.def
apptainer build nanoconfinement.sif Apptainer.def

