#!/bin/bash


PROFILE=$2
LOGS="work"
PARAMS="params.json"

mkdir -p ${LOGS}

wait_for(){
    PID=$(echo "$1" | cut -d ":" -f 1 )
    PRO=$(echo "$1" | cut -d ":" -f 2 )
    echo "$(date '+%Y-%m-%d %H:%M:%S'): waiting for ${PRO}"
    wait $PID
    CODE=$?
    
    if [[ "$CODE" != "0" ]] ; 
        then
            echo "$PRO failed"
            echo "$CODE"
            failed=true
            #exit $CODE
    fi
}

failed=false


  for repo in nf-fastqc nf-flexbar nf-bowtie2 nf-kallisto nf-multiqc nf-macs  nf-diffbind nf-ATACseqQC nf-bedGraphToBigWig nf-CHIPseeker; 
    do

      if [[ ! -e ${repo} ]] ;
        then
          git clone git@github.com:mpg-age-bioinformatics/${repo}.git
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

get_images() {
  echo "- downloading images"
  nextflow run ${ORIGIN}nf-fastqc ${FASTQC_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} >> ${LOGS}/get_images.log 2>&1 && \
  nextflow run ${ORIGIN}nf-kallisto ${KALLISTO_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} >> ${LOGS}/get_images.log 2>&1 && \
  nextflow run ${ORIGIN}nf-flexbar ${FLEXBAR_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} >> ${LOGS}/get_images.log 2>&1 && \
  nextflow run ${ORIGIN}nf-bowtie2 ${BOWTIE2_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} >> ${LOGS}/get_images.log 2>&1 && \
  nextflow run ${ORIGIN}nf-macs ${MACS_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} >> ${LOGS}/get_images.log 2>&1 && \
  nextflow run ${ORIGIN}nf-multiqc ${MULTIQC_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} >> ${LOGS}/get_images.log 2>&1 && \
  nextflow run ${ORIGIN}nf-diffbind ${DIFFBIND_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} >> ${LOGS}/get_images.log 2>&1
  nextflow run ${ORIGIN}nf-ATACseqQC ${ATACSEQQC_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} >> ${LOGS}/get_images.log 2>&1 && \
  nextflow run ${ORIGIN}nf-bedGraphToBigWig $BEDGRAPHTOBIGWIG_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} >> ${LOGS}/get_images.log 2>&1 && \
  nextflow run ${ORIGIN}nf-CHIPseeker ${CHIPSEEKER_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} >> ${LOGS}/get_images.log 2>&1
}

run_fastqc() {
  echo "- running fastqc"  
  nextflow run ${ORIGIN}nf-fastqc ${FASTQC_RELEASE} -params-file ${PARAMS} -profile ${PROFILE} >> ${LOGS}/nf-fastqc.log 2>&1 
  # nextflow run ${ORIGIN}nf-fastqc ${FASTQC_RELEASE} -params-file ${PARAMS} -entry upload -profile ${PROFILE} >> ${LOGS}/nf-fastqc.log 2>&1
  echo "- running fastqc done" 
}

run_flexbar() {
  echo "- running flexbar"  
  nextflow run ${ORIGIN}nf-flexbar ${FLEXBAR_RELEASE} -params-file ${PARAMS} -profile ${PROFILE} >> ${LOGS}/nf-flexbar.log 2>&1 
  echo "- running flexbar done"  
}

run_bowtie2() {
  echo "- running bowtie2"  
  nextflow run ${ORIGIN}nf-kallisto ${KALLISTO_RELEASE} -params-file ${PARAMS} -entry get_genome  -profile ${PROFILE} >> ${LOGS}/nf-bowtie2.log 2>&1 && \
  nextflow run ${ORIGIN}nf-bowtie2 ${BOWTIE2_RELEASE} -params-file ${PARAMS} -entry index -profile ${PROFILE} >> ${LOGS}/nf-bowtie2.log 2>&1 && \
  nextflow run ${ORIGIN}nf-bowtie2 ${BOWTIE2_RELEASE} -params-file ${PARAMS} -entry align -profile ${PROFILE} >> ${LOGS}/nf-bowtie2.log 2>&1 && \
  nextflow run ${ORIGIN}nf-bowtie2 ${BOWTIE2_RELEASE} -params-file ${PARAMS} -entry mito -profile ${PROFILE} >> ${LOGS}/nf-bowtie2.log 2>&1 && \
  nextflow run ${ORIGIN}nf-bowtie2 ${BOWTIE2_RELEASE} -params-file ${PARAMS} -entry picard -profile ${PROFILE} >> ${LOGS}/nf-bowtie2.log 2>&1 && \
  nextflow run ${ORIGIN}nf-bowtie2 ${BOWTIE2_RELEASE} -params-file ${PARAMS} -entry flagstat -profile ${PROFILE} >> ${LOGS}/nf-bowtie2.log 2>&1 && \
  nextflow run ${ORIGIN}nf-bowtie2 ${BOWTIE2_RELEASE} -params-file ${PARAMS} -entry qccount -profile ${PROFILE}>> ${LOGS}/nf-bowtie2.log 2>&1 
  echo "- running bowtie2 done"  
}


run_multiqc() {
  echo "- running multiqc" && \
  nextflow run ${ORIGIN}nf-multiqc ${MULTIQC_RELEASE} -params-file ${PARAMS} -profile ${PROFILE} >> ${LOGS}/multiqc.log 2>&1 
  #&& \
  # nextflow run ${ORIGIN}nf-multiqc ${MULTIQC_RELEASE} -params-file ${PARAMS} -entry upload -profile ${PROFILE} >> ${LOGS}/multiqc.log 2>&1
}


run_ATACseqQC() {
  echo "- running ATACseqQC"  
  nextflow run ${ORIGIN}nf-ATACseqQC ${ATACSEQQC_RELEASE} -params-file ${PARAMS} -profile ${PROFILE}>> ${LOGS}/nf-ATACseqQC.log 2>&1 
  echo "- running ATACseqQC done"  
}


run_macs() {
  echo "- running macs"  
  nextflow run ${ORIGIN}nf-diffbind ${DIFFBIND_RELEASE} -params-file ${PARAMS} -entry samplesheet -profile ${PROFILE}>> ${LOGS}/nf-macs.log 2>&1 
  nextflow run ${ORIGIN}nf-macs ${MACS_RELEASE} -params-file ${PARAMS} -profile ${PROFILE}>> ${LOGS}/nf-macs.log 2>&1 
  echo "- running macs done"  
}

run_bedGraphToBigWig() {
  echo "- running bedGraphToBigWig"  
  nextflow run ${ORIGIN}nf-bedGraphToBigWig ${BEDGRAPHTOBIGWIG_RELEASE} -params-file ${PARAMS} -profile ${PROFILE}>> ${LOGS}/nf-bedGraphToBigWig.log 2>&1 
  echo "- running bedGraphToBigWig done"  
}

run_diffbind() {
  echo "- running diffbind"  
  nextflow run ${ORIGIN}nf-diffbind ${DIFFBIND_RELEASE} -params-file ${PARAMS} -profile ${PROFILE}>> ${LOGS}/nf-diffbind.log 2>&1 
  echo "- running diffbind done"  
}

run_CHIPseeker() {
  echo "- running CHIPseeker"  
  nextflow run ${ORIGIN}nf-CHIPseeker ${CHIPSEEKER_RELEASE} -params-file ${PARAMS} -profile ${PROFILE}>> ${LOGS}/nf-CHIPseeker.log 2>&1 
  echo "- running CHIPseeker done"  
}



get_images && sleep 1
run_fastqc && sleep 1
run_flexbar && sleep 1
run_bowtie2 && sleep 1

run_multiqc & RUN_multiqc_PID=$!
run_ATACseqQC & RUN_ATACseqQC_PID=$!

run_macs && sleep 1
run_bedGraphToBigWig & RUN_bedGraphToBigWig_PID=$!
run_diffbind && sleep 1
run_CHIPseeker & RUN_CHIPseeker_PID=$!

for PID in "${RUN_multiqc_PID}:MULTIQC" \
 "${RUN_ATACseqQC_PID}:ATACseqQC" \ 
 "${RUN_bedGraphToBigWig_PID}:bedGraphToBigWig" \ 
 "${RUN_CHIPseeker_PID}:CHIPseeker"
  do
    wait_for $PID
done

if [ "$failed" = true ]; then

  echo "At least one process failed. Exiting."
  exit 1

else

  echo "All processes completed successfully. Proceeding to the next step."