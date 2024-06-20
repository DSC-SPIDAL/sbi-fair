# Development notes
### Regenerate files from cookiecutter templates
Create new files only, keep the existing ones intact
```bash
cd models
for surrogate in *; do 
(
    cd $surrogate
    pipx run cookiecutter ../../tools/cookiecutter_template -f -s -o ../ --no-input project_name=${PWD##*/}
) 
done
```

