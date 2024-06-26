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

### Test and simple benchmark
The test system is set up to by default run all tests configured in ${MODEL}/tests for all surrogates. The tests will be run in benchmark mode i.e. by default there will be 5 timed runs for each test. 
To run in this mode run `pytest tools/tests`. Requires installed `pytest` and `pytest-benchmark`

1. Test without running benchmarks `pytest tools/tests --benchmark-disable`
2. Run all tests with benchmarks for single surrogate, single container system and using GPU: `pytest tools/tests -k 'not cpu' --container-systems apptainer --surrogates nanoconfinement`

