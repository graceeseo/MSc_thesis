# Appendix 3.1 BASH code for data analysis
# Grace Seo

# Contains detailed code for data transfer and Guppy basecalling 

###===============================================###
### Transfer data from GridION to server computer ###
###===============================================###

while true ; do date ; time rsync -r RUN_NAME /DATABASE_FOLDER_PATH ; sleep 180 ; done





###================================================================###
### Guppy basecalling on fast5 files using fast basecalling module ###
###================================================================###

### April 9, 2022 fast basecalling vs. high-accuracy basecalling test GC_231A (ligation sequencing kit) and GC_231B (rapid barcoding kit)


###########################################################################
###########################################################################
###                                                                     ###
###          GC_231A and GC_231B working guppy gpu code                 ###
###                                                                     ###
###########################################################################
###########################################################################
(fast basecalling script and COVID nextflow analysis)

###########################################################################
### WORKING BASECALLING METHOD - GUPPY GPU

cd $INPUT

mkdir -p $OUTPUT/GS_nextflow_analyses_Apr9_1618_FreedV1_FastBC
cd $OUTPUT/GS_nextflow_analyses_Apr9_1618_FreedV1_FastBC

ln -s $INPUT .


touch fast_basecalling_gpu.sh
nano fast_basecalling_gpu.sh


## copy and paste the following into the script
################## BASH SCRIPT ########################
#!/bin/bash

# Set the numbr of parallel runs to do for basecalling
parallel_basecalling=6

# Sets the number of gpus on the node
# Currently not working, have to find a way to put into cuda part
gpus=2

for folder in `ls -1 -d */`; do echo $folder; done | parallel -j $parallel_basecalling guppy_basecaller -c dna_r9.4.1_450bps_fast.cfg -r -i {} -s fastq_pass_dehosted_only/{} -x \"cuda:'{= $_=$job->slot()%2=}'\"

################## End of BASH SCRIPT ########################

chmod 755 fast_basecalling_gpu.sh

conda init
conda activate guppy-4.0.11-gpu

sbatch $CONFIG --gres=gpu:v100:2 -J GC_231A_fastBC --wrap="./fast_basecalling_gpu.sh"

conda deactivate

sacct --format="Elapsed" -j 12084038
### took about 1 day + 16 hours


##-------------------------------------------------------------------------
##  1. Create variables and a folder                                      -
##-------------------------------------------------------------------------

PARENT_DIR=""
BASE_DIR=""
FAST5_PASS=${PARENT_DIR}/fast5_pass
FASTBC_FASTQ=""


##-------------------------------------------------------------------------
##  4. Combine all fastq files into one fastq                             -
##-------------------------------------------------------------------------

cd $INPUT/GS_nextflow_analyses_Apr9_1618_FreedV1_FastBC

mkdir -p all_reads

## CHANGE JOB ID AFTEROK
sbatch -c 4 --mem=16G -p NMLResearch -J combining_fastqfiles --dependency=afterok:$PREVIOUS_JOB --wrap="cat ${FASTBC_FASTQ}/*.fastq >> ./all_reads/results_all.fastq"


##-------------------------------------------------------------------------
##  5. Demultiplex newly basecalled fastq file                            -
##-------------------------------------------------------------------------

## EXAMPLE: sbatch $CONFIG -J stricBarcoding --wrap="guppy_barcoder -i all_reads -s barcodes_strict_demulti --barcode_kits EXP-NBD104" 
## EXAMPLE: sbatch $CONFIG -J stricBarcoding --wrap="guppy_barcoder -i all_reads -s barcodes_strict_demulti --barcode_kits EXP-NBD114" 

conda activate guppy-4.0.11-cpu


sbatch $CONFIG -J stricBarcoding --dependency=afterok:$PREVIOUS_JOB --wrap="guppy_barcoder -i all_reads -s barcodes_strict_demulti --barcode_kits EXP-NBD196" 


conda deactivate


##-------------------------------------------------------------------------
##  6. Make a run folder and move barcodes_strict_demulti to fastq_pass   -
##-------------------------------------------------------------------------

mkdir -p run
mv barcodes_strict_demulti/ run/fastq_pass


##-------------------------------------------------------------------------
##  7. Change directory and create sym links                              -
##-------------------------------------------------------------------------

cd $OUTPUT/GS_nextflow_analyses_Apr9_1618_FreedV1_FastBC

ln -s ${BASE_DIR}/samplesheet.tsv .

cd run
ln -s ${PARENT_DIR}/sequencing_summary*.txt .
ln -s ${PARENT_DIR}/fast5_pass .
cd ../
#pwd: $INPUT/GS_nextflow_analyses_Apr9_1618_FreedV1_FastBC

### USE DEHOSTED OPTION SINCE ALREADY REBASECALLED
srun -p NMLResearch bash $NEXTFLOWPIPELINE/pipeline_nextflow.sh -d ./run -p freed --dehosted





