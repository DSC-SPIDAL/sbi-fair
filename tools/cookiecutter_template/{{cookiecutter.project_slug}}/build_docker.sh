#!/bin/bash
rm -r helpers
cp -a ../../tools/helpers .
docker build -t {{ cookiecutter.project_slug }} .
