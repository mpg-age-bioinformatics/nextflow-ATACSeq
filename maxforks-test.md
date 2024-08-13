test on `hpc`

Create the test directory:
```
mkdir -p ~/maxforks_test
```

Download the demo data:
```
cd ~/maxforks_test
curl -J -O https://datashare.mpcdf.mpg.de/s/PcBd0kCPH7k82Z4/download
unzip raw_data.zip
```

download nf-fastqc repo:
```
git clone https://github.com/mpg-age-bioinformatics/nf-fastqc.git
```

change `~/maxforks_test/nf-fastqc/params.json` to
```
{ 
  "project_folder" : "/nexus/posix0/MAGE-flaski/service/hpc/home/wangy/maxforks_test" ,
  "fastqc_raw_data" : "/nexus/posix0/MAGE-flaski/service/hpc/home/wangy/maxforks_test" 
}
```

change `~/maxforks_test/nf-fastqc/nextflow.condig` to
```
  studio {
    process {
      maxForks=1
    }
    ...
    ...
```

Run and monintor the run:
```
PROFILE=studio
nextflow run nf-fastqc -params-file nf-fastqc/params.json -entry images -profile ${PROFILE} && \
nextflow run nf-fastqc -params-file nf-fastqc/params.json -profile ${PROFILE}
```

Results:
now the process runs sequential