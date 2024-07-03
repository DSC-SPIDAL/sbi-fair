#!/bin/sh
head -n 300 ${1} > tmp.txt
mv tmp.txt ${1}