#!/bin/bash
mkdir -p ${SCIF_APPROOT}/bin
cp ${PROJECT_DIR}/train_mpi.py ${SCIF_APPROOT}/bin
chmod +x ${SCIF_APPROOT}/bin/train_mpi.py