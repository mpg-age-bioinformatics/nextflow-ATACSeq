#!/bin/bash

## usage:
## $1 : `release` for latest nextflow/git release; `checkout` for git clone followed by git checkout of a tag ; `clone` for latest repo commit
## $2 : /path/to/params.json


PROFILE=local
LOGS="work"
PARAMS="/Users/YWang/nf/nextflow-ATACSeq/params.local.json"

mkdir -p ${LOGS}

ORIGIN="/Users/YWang/nf/"


get_images() {
  echo "- downloading images"  
  nextflow run ${ORIGIN}nf-fastqc ${FASTQC_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} >> ${LOGS}/get_images.log 2>&1 
  nextflow run ${ORIGIN}nf-flexbar ${FLEXBAR_RELEASE} -params-file ${PARAMS} -entry images -profile ${PROFILE} >> ${LOGS}/get_images.log 2>&1
  echo "- downloading images done" 
 }

run_fastqc() {
  echo "- running fastqc"  
  nextflow run ${ORIGIN}nf-fastqc ${FASTQC_RELEASE} -params-file ${PARAMS} -profile ${PROFILE} >> ${LOGS}/nf-fastqc.log 2>&1 
  nextflow run ${ORIGIN}nf-fastqc ${FASTQC_RELEASE} -params-file ${PARAMS} -entry upload -profile ${PROFILE} >> ${LOGS}/nf-fastqc.log 2>&1
  echo "- running fastqc done" 
}

run_flexbar() {
  echo "- running flexbar"  
  nextflow run ${ORIGIN}nf-flexbar ${FASTQC_RELEASE} -params-file ${PARAMS} -profile ${PROFILE} >> ${LOGS}/nf-flexbar.log 2>&1 
  echo "- running flexbar done"  
}


get_images 
run_fastqc 
run_flexbar 

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