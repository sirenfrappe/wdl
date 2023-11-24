# docker img
https://hub.docker.com/r/naotokubota/qtltools

# input files
same format from https://qtltools.github.io/qtltools/

## nominal.nominal_pass.out_name
used to name the output file.

# run
```shell
java -DLOG_LEVEL=ERROR -jar /path/to/cromwell-85.jar run qtltools.wdl --inputs src/qtltools_json/"$tissue_name".json
```
seed was set 618 in `q`tltools.wdl`