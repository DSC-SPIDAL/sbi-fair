#!/bin/bash
mkdir -p ${SCIF_APPROOT}/bin
mkdir -p ${SCIF_APPDATA}
cp train.py ${SCIF_APPROOT}/bin
cp evaluate.py ${SCIF_APPROOT}/bin
cp run.py ${SCIF_APPROOT}/bin
cp  ${SCIF_APPDATA}