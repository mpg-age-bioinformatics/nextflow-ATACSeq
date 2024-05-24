# nextflow-ATACSeq

This workflow is based on the following nextflow pipes:

- https://github.com/mpg-age-bioinformatics/nf-fastqc
- https://github.com/mpg-age-bioinformatics/nf-flexbar
- https://github.com/mpg-age-bioinformatics/nf-mageck
- https://github.com/mpg-age-bioinformatics/nf-bowtie2
- https://github.com/mpg-age-bioinformatics/nf-macs
- https://github.com/mpg-age-bioinformatics/nf-diffbind
- https://github.com/mpg-age-bioinformatics/nf-CHIPseeker
- https://github.com/mpg-age-bioinformatics/nf-bedGraphToBigWig
- https://github.com/mpg-age-bioinformatics/nf-ATACseqQC

## local test
bash nextflow-local.sh clone params.local.json

Once run is complete you will find in the `work` folder the file `software.txt` with information on all the respective versions used for your run.

## flaski
If you have a flaski config file you can extract the parameters file from it with:

```
nextflow run mpg-age-bioinformatics/nf-flaski-configs -r 1.0.0 --raw </path/to/raw/data> --json </path/to/flaski/config.json --out </path/to/output> -profile local
```

And then run the workflow with:
```
bash nextflow-local.sh clone </path/to/output/params.json>
```




