#!/bin/bash

# SLURM header
#SBATCH --job-name=consensus_gen
#SBATCH -e consensus_gen%j.e.txt
#SBATCH -o consensus_gen.log.%j.out
#SBATCH -c 5    # (cpu cores per task)
#SBATCH -p medmem  # partitians= standard= 96G; medmem=192G; himem = 1.5TB
#SBATCH -t 2-0
#SBATCH --array=1-3 # The total number of possible pairwise comparisons from a list of #SBATCH --ntasks=1
##########################################################################################

module load bio/angsd/0.940

ProjDir=/home/pmorin/projects/Pcra/hPSMC_Dsuite_June2025
OUTDIR=${ProjDir}/hPSMC_consensus_sequences
BAMLIST=bamlist.txt
# Generate the list of files including paths to each file, e.g., '/share/swfsc/pmorin/Pcra_z0018462_dedup_noRepeats.bam'.
THREADS=5
baseQ=25 # minimum base quality
mapQ=25 # minimum map quality

mkdir -p ${OUTDIR}
mkdir -p ${error}


readarray -t files < ${ProjDir}/${BAMLIST}

cd ${ProjDir}
# Get the bam filename for this array task
current_file=${files[$SLURM_ARRAY_TASK_ID-1]}
# parse the filename to extract the filename from the path
file=`echo $current_file | cut -f5 -d "/"`
echo ${file}

# parse the species abbreviation (first part of the filename) and sample ID (2nd part of the filename).
sp=`echo $file | cut -f1 -d "_"`
echo ${sp}
ID=`echo ${file} | cut -f2 -d "_"`
echo ${ID}

# List of chromosomes (only autosomes) to include (space-separated) (from reference genome)
# check chr names in bam using samtools view -H Pcra_z0018462_dedup_noRepeats.bam | head -25
CHROMOSOMES=("NC_090296.1" "NC_090297.1" "NC_090298.1" "NC_090299.1" "NC_090300.1" "NC_090301.1" "NC_090302.1" "NC_090303.1" "NC_090304.1" "NC_090305.1" "NC_090306.1" "NC_090307.1" "NC_090308.1" "NC_090309.1" "NC_090310.1" "NC_090311.1" "NC_090312.1" "NC_090313.1" "NC_090314.1" "NC_090315.1" "NC_090316.1")

# Convert array to ANGSD format (comma-separated)
CHROM_LIST=$(IFS=,; echo "${CHROMOSOMES[*]}")

# generate consensus genome
angsd -i ${current_file} -nThreads ${THREADS} -doFasta 2 -minQ ${baseQ} -minmapq ${mapQ} -uniqueonly 1 -remove_bads 1 -setMinDepthInd 5 -doCounts 1 -rf <(echo -e "${CHROMOSOMES[*]}" | tr ' ' '\n') -out ${OUTDIR}/${sp}_${ID}_hPSMC_autosome_consensus

