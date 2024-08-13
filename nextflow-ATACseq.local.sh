#!/bin/bash

## usage:
## $1 : `release` for latest nextflow/git release; `checkout` for git clone followed by git checkout of a tag ; `clone` for latest repo commit
## $2 : /path/to/params.json

# source ATACseq.config

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

failed=false

PROFILE="standard"
LOGS="work"
PARAMS="${2}"

mkdir -p ${LOGS}

if [[ "$1" == "release" ]] ; 
  then

    ORIGIN="mpg-age-bioinformatics/"
    FASTQC_RELEASE=$(get_latest_release ${ORIGIN}nf-fastqc)
    echo "${ORIGIN}nf-fastqc:${FASTQC_RELEASE}" >> ${LOGS}/software.txt
    FASTQC_RELEASE="-r ${FASTQC_RELEASE}"

    KALLISTO_RELEASE=$(get_latest_release ${ORIGIN}nf-kallisto)
    echo "${ORIGIN}nf-kallisto:${KALLISTO_RELEASE}" >> ${LOGS}/software.txt
    KALLISTO_RELEASE="-r ${KALLISTO_RELEASE}"

    FLEXBAR_RELEASE=$(get_latest_release ${ORIGIN}nf-flexbar)
    echo "${ORIGIN}nf-flexbar:${FLEXBAR_RELEASE}" >> ${LOGS}/software.txt
    FLEXBAR_RELEASE="-r ${FLEXBAR_RELEASE}"

    BOWTIE2_RELEASE=$(get_latest_release ${ORIGIN}nf-bowtie2)
    echo "${ORIGIN}nf-bowtie2:${BOWTIE2_RELEASE}" >> ${LOGS}/software.txt
    BOWTIE2_RELEASE="-r ${BOWTIE2_RELEASE}"
    
    MACS_RELEASE=$(get_latest_release ${ORIGIN}nf-macs)
    echo "${ORIGIN}nf-macs:${MACS_RELEASE}" >> ${LOGS}/software.txt
    MACS_RELEASE="-r ${MACS_RELEASE}"
    
    MULTIQC_RELEASE=$(get_latest_release ${ORIGIN}nf-multiqc)
    echo "${ORIGIN}nf-multiqc:${MULTIQC_RELEASE}" >> ${LOGS}/software.txt
    MULTIQC_RELEASE="-r ${MULTIQC_RELEASE}"

    DIFFBIND_RELEASE=$(get_latest_release ${ORIGIN}nf-diffbind)
    echo "${ORIGIN}nf-diffbind:${DIFFBIND_RELEASE}" >> ${LOGS}/software.txt
    DIFFBIND_RELEASE="-r ${DIFFBIND_RELEASE}"
        
    ATACSEQQC_RELEASE=$(get_latest_release ${ORIGIN}nf-ATACseqQC)
    echo "${ORIGIN}nf-ATACseqQC:${ATACSEQQC_RELEASE}" >> ${LOGS}/software.txt
    ATACSEQQC_RELEASE="-r ${ATACSEQQC_RELEASE}"
    
    BEDGRAPHTOBIGWIG_RELEASE=$(get_latest_release ${ORIGIN}nf-bedGraphToBigWig)
    echo "${ORIGIN}nf-bedGraphToBigWig:${BEDGRAPHTOBIGWIG_RELEASE}" >> ${LOGS}/software.txt
    BEDGRAPHTOBIGWIG_RELEASE="-r ${BEDGRAPHTOBIGWIG_RELEASE}"

    CHIPSEEKER_RELEASE=$(get_latest_release ${ORIGIN}nf-CHIPseeker)
    echo "${ORIGIN}nf-CHIPseeker:${CHIPSEEKER_RELEASE}" >> ${LOGS}/software.txt
    CHIPSEEKER_RELEASE="-r ${CHIPSEEKER_RELEASE}"

    uniq ${LOGS}/software.txt ${LOGS}/software.txt_
    mv ${LOGS}/software.txt_ ${LOGS}/software.txt
else

  for repo in nf-fastqc nf-flexbar nf-bowtie2 nf-kallisto nf-multiqc nf-macs  nf-diffbind nf-ATACseqQC nf-bedGraphToBigWig nf-CHIPseeker; 
    do

      if [[ ! -e ${repo} ]] ;
        then
          git clone https://github.com/mpg-age-bioinformatics/${repo}.git
      fi

      if [[ "$1" == "checkout" ]] ;
        then
          cd ${repo}
          git pull
          RELEASE=$(get_latest_release ${ORIGIN}${repo})
          git checkout ${RELEASE}
          cd ../
          echo "${ORIGIN}${repo}:${RELEASE}" >> ${LOGS}/software.txt
      else
        cd ${repo}
        COMMIT=$(git rev-parse --short HEAD)
        cd ../
        echo "${ORIGIN}${repo}:${COMMIT}" >> ${LOGS}/software.txt
      fi
  done

  uniq ${LOGS}/software.txt >> ${LOGS}/software.txt_ 
  mv ${LOGS}/software.txt_ ${LOGS}/software.txt
fi

get_images() {
  echo "- downloading images"
  nextflow run ${ORIGIN}nf-fastqc ${FASTQC_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/get_images.log 2>&1 && \
  nextflow run ${ORIGIN}nf-kallisto ${KALLISTO_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/get_images.log 2>&1 && \
  nextflow run ${ORIGIN}nf-flexbar ${FLEXBAR_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/get_images.log 2>&1 && \
  nextflow run ${ORIGIN}nf-bowtie2 ${BOWTIE2_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/get_images.log 2>&1 && \
  nextflow run ${ORIGIN}nf-macs ${MACS_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/get_images.log 2>&1 && \
  nextflow run ${ORIGIN}nf-multiqc ${MULTIQC_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/get_images.log 2>&1 && \
  nextflow run ${ORIGIN}nf-diffbind ${DIFFBIND_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/get_images.log 2>&1
  nextflow run ${ORIGIN}nf-ATACseqQC ${ATACSEQQC_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/get_images.log 2>&1 && \
  nextflow run ${ORIGIN}nf-bedGraphToBigWig $BEDGRAPHTOBIGWIG_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/get_images.log 2>&1 && \
  nextflow run ${ORIGIN}nf-CHIPseeker ${CHIPSEEKER_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/get_images.log 2>&1
}

run_fastqc() {
  echo "- running fastqc"  
  nextflow run ${ORIGIN}nf-fastqc ${FASTQC_RELEASE} -params-file ${PARAMS} -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/nf-fastqc.log 2>&1 
  nextflow run ${ORIGIN}nf-fastqc ${FASTQC_RELEASE} -params-file ${PARAMS} -entry upload -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/nf-fastqc.log 2>&1
  echo "- running fastqc done" 
}

run_flexbar() {
  echo "- running flexbar"  
  nextflow run ${ORIGIN}nf-flexbar ${FLEXBAR_RELEASE} -params-file ${PARAMS} -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/nf-flexbar.log 2>&1 
  echo "- running flexbar done"  
}

run_bowtie2() {
  echo "- running bowtie2"  
  nextflow run ${ORIGIN}nf-kallisto ${KALLISTO_RELEASE} -params-file ${PARAMS} -entry get_genome  -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/nf-bowtie2.log 2>&1 && \
  nextflow run ${ORIGIN}nf-bowtie2 ${BOWTIE2_RELEASE} -params-file ${PARAMS} -entry index -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/nf-bowtie2.log 2>&1 && \
  nextflow run ${ORIGIN}nf-bowtie2 ${BOWTIE2_RELEASE} -params-file ${PARAMS} -entry align -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/nf-bowtie2.log 2>&1 && \
  nextflow run ${ORIGIN}nf-bowtie2 ${BOWTIE2_RELEASE} -params-file ${PARAMS} -entry mito -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/nf-bowtie2.log 2>&1 && \
  nextflow run ${ORIGIN}nf-bowtie2 ${BOWTIE2_RELEASE} -params-file ${PARAMS} -entry picard -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/nf-bowtie2.log 2>&1 && \
  nextflow run ${ORIGIN}nf-bowtie2 ${BOWTIE2_RELEASE} -params-file ${PARAMS} -entry flagstat -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/nf-bowtie2.log 2>&1 && \
  nextflow run ${ORIGIN}nf-bowtie2 ${BOWTIE2_RELEASE} -params-file ${PARAMS} -entry qccount -profile ${PROFILE} --user "$(id -u):$(id -g)" >> ${LOGS}/nf-bowtie2.log 2>&1 
  echo "- running bowtie2 done"  
}


run_multiqc() {
  echo "- running multiqc" && \
  nextflow run ${ORIGIN}nf-multiqc ${MULTIQC_RELEASE} -params-file ${PARAMS} -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/nf-multiqc.log 2>&1 && \
  nextflow run ${ORIGIN}nf-multiqc ${MULTIQC_RELEASE} -params-file ${PARAMS} -entry upload -profile ${PROFILE} --user "$(id -u):$(id -g)"  >> ${LOGS}/multiqc.log 2>&1
}


run_ATACseqQC() {
  echo "- running ATACseqQC"  
  nextflow run ${ORIGIN}nf-ATACseqQC ${ATACSEQQC_RELEASE} -params-file ${PARAMS} -profile ${PROFILE} --user "$(id -u):$(id -g)" >> ${LOGS}/nf-ATACseqQC.log 2>&1 
  nextflow run ${ORIGIN}nf-ATACseqQC ${ATACSEQQC_RELEASE} -params-file ${PARAMS}  -entry upload -profile ${PROFILE} --user "$(id -u):$(id -g)" >> ${LOGS}/nf-ATACseqQC.log 2>&1 
  echo "- running ATACseqQC done"  
}


run_macs() {
  echo "- running macs"  
  nextflow run ${ORIGIN}nf-diffbind ${DIFFBIND_RELEASE} -params-file ${PARAMS} -entry samplesheet -profile ${PROFILE} --user "$(id -u):$(id -g)" >> ${LOGS}/nf-macs.log 2>&1 
  nextflow run ${ORIGIN}nf-macs ${MACS_RELEASE} -params-file ${PARAMS} -profile ${PROFILE} --user "$(id -u):$(id -g)" >> ${LOGS}/nf-macs.log 2>&1 
  echo "- running macs done"  
}

run_bedGraphToBigWig() {
  echo "- running bedGraphToBigWig"  
  nextflow run ${ORIGIN}nf-bedGraphToBigWig ${BEDGRAPHTOBIGWIG_RELEASE} -params-file  ${PARAMS} -entry bedgraphtobigwig_ATACseq  -profile ${PROFILE} --user "$(id -u):$(id -g)" >> ${LOGS}/nf-bedGraphToBigWig.log 2>&1 
  nextflow run ${ORIGIN}nf-bedGraphToBigWig ${BEDGRAPHTOBIGWIG_RELEASE} -params-file ${PARAMS} -entry upload  -profile ${PROFILE} --user "$(id -u):$(id -g)" >> ${LOGS}/nf-bedGraphToBigWig.log 2>&1 
  echo "- running bedGraphToBigWig done"  
}

run_diffbind() {
  echo "- running diffbind"  
  nextflow run ${ORIGIN}nf-diffbind ${DIFFBIND_RELEASE} -params-file ${PARAMS} -profile ${PROFILE} --user "$(id -u):$(id -g)" >> ${LOGS}/nf-diffbind.log 2>&1 
  echo "- running diffbind done"  
}

run_CHIPseeker() {
  echo "- running CHIPseeker"  
  nextflow run ${ORIGIN}nf-CHIPseeker ${CHIPSEEKER_RELEASE} -params-file ${PARAMS} -profile ${PROFILE} --user "$(id -u):$(id -g)" >> ${LOGS}/nf-CHIPseeker.log 2>&1 
  nextflow run ${ORIGIN}nf-diffbind ${DIFFBIND_RELEASE} -params-file ${PARAMS} -entry upload -profile ${PROFILE} --user "$(id -u):$(id -g)" >> ${LOGS}/nf-diffbind.log 2>&1 
  echo "- running CHIPseeker done"  
}



get_images && \
run_fastqc && \
run_flexbar && \
run_bowtie2 && \
run_multiqc && \
run_ATACseqQC && \
run_macs && \
run_bedGraphToBigWig && \
run_diffbind && \
run_CHIPseeker 


LOGS=$(readlink -f ${LOGS})
project_folder=$(grep project_folder ${PARAMS} | awk -F\" '{print $4}' )
eval cd ${project_folder}
rm -rf upload.txt
cat $(find . -name upload.txt) > upload.txt
mkdir -p summary
while read line ; 
  do 
    folder=$(echo ${line} | awk '{ st = index($0," ");print $1}')
    ref=$(echo ${line} | awk '{ st = index($0," ");print substr($0,st+1)}')
    if [[ "${folder}" != "main" ]] ;
      then
        target=summary/${folder}/$(basename ${ref})
        mkdir -p summary/${folder}
    else
      target=summary/$(basename ${ref})
    fi
  ln -s ${ref} ${target}
done < upload.txt

echo "- done"
exit