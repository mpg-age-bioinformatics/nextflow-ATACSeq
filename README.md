# nextflow-ATACSeq


- [ ] fastqc
- [ ] flexbar
- [ ] fastqc on flexbar
- [ ] bowtie
- [ ] macs2
- [ ] deeptools/bam2bigwig


PARAMS=/Users/YWang/nf/nextflow-ATACSeq/params.local.json
PROFILE=local
nextflow run nf-fastqc -params-file ${PARAMS} -entry images -profile ${PROFILE}
nextflow run nf-fastqc -params-file ${PARAMS} -profile ${PROFILE}
nextflow run nf-fastqc -params-file ${PARAMS} -entry upload -profile ${PROFILE}

nextflow run nf-flexbar -params-file ${PARAMS} -entry images -profile ${PROFILE}
nextflow run nf-flexbar ${FASTQC_RELEASE} -params-file ${PARAMS} -profile ${PROFILE}

nextflow run nf-fastqc -params-file ${PARAMS} --fastqc_raw_data="/Users/YWang/nf/nf-flexbar-test/trimmed_raw"  --fastqc_output="fastq_trimmed_output" -profile ${PROFILE}
nextflow run nf-fastqc -params-file ${PARAMS} -entry upload -profile ${PROFILE}

PARAMS=/Users/YWang/nf/nf-bowtie2/params.json
nextflow run nf-bowtie2 -params-file ${PARAMS} -entry images -profile ${PROFILE}
nextflow run nf-bowtie2 -params-file ${PARAMS} -profile ${PROFILE}
# sanger, solexa, i1.3, i1.5, and i1.8


