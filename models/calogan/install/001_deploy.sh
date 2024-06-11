#!/bin/bash
mkdir -p ${SCIF_APPROOT}
cp -a ${PROJECT_DIR} ${SCIF_APPROOT}/
chmod +x ${SCIF_APPROOT_model}/${PROJECT_DIR}/models/train.py