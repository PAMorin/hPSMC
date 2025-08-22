#! /bin/bash

# SLURM header
#SBATCH --job-name=hPSMC
#SBATCH -e hPSMC%j.e.txt
#SBATCH -o hPSMC.log.%j.out
#SBATCH -c 10
#SBATCH -p standard  # partitians= standard= 96G; medmem=192G; himem = 1.5TB
#SBATCH --mem=40G
#SBATCH -t 3-0
#SBATCH --array=1-3
#SBATCH --ntasks=1
##########################################################################################

#programs
module load bio/samtools/1.11
module load bio/bcftools/1.11
module load tools/gnuplot/5.4.1
PSMC=~/programs/psmc

set -eux
##############################################################

INDIR=/home/pmorin/projects/Pcra/hPSMC_Dsuite_June2025/hPSMC
psmcfa_DIR=${INDIR}/psmcfa_files
OUTDIR=${INDIR}/hPSMC_output
mkdir -p ${OUTDIR}
psmcfa_files=psmcfa_files.txt # lists psmcfa files; e.g., ls -1 *.psmcfa > psmcfa_files.txt
THREADS=10

# PSMC parameters
TEMP_DIR=/scratch/pmorin/temp
MUT=4.90E-10 #mutation rate (µ/site/yr)
# Robinson et al. 2023 (doi 10.1126/science.abm1742, suppl. material) estimate for vaquita is 4.90E-10 sub/site/yr (from 5.83E-9 sub/site/gen, generation time = 11.9yr).
GEN=24 # based on pilot whale. from Taylor et al. 2007, Table 1, T(r=0)=generation length under pre-disturbance conditions. 

MUTRATE=$(echo $GEN $MUT | awk '{ printf "%.12f", $1*$2 }') # mutation rate (µ/site/yr) multiplied by generation time. 

MUT2=4.90E10_msy	# msy=mutations per site per year for printing mutation rate on plot and in file name

t=15	# default from Li and Durbin 2011 is 15
PSMC_INT="4+25*2+4+6" # default from Li and Durbin 2011 is 4+25*2+4+6; 

#########################################################################
#########################################################################
# read filenames
readarray -t files < ${psmcfa_DIR}/${psmcfa_files}

# Get the file for this array task
current_file=${files[$SLURM_ARRAY_TASK_ID-1]}
short1=`echo $current_file | cut -f1 -d "."` # everything before "."
short_file=`echo $short1 | cut -f2,3 -d "_"` # two species names when filenames like "hPSMC_Mgra_Mste.psmcfa"

#########################################################################
# PSMC
ID=${short_file}

#generate the psmc file using the default settings for humans (-N25, -t15, -r5).
${PSMC}/psmc -N25 -t${t} -r5 -p ${PSMC_INT} -o ${OUTDIR}/${ID}_${MUT2}_t${t}.psmc ${psmcfa_DIR}/$current_file

#Make psmc plots and adapt the scaling using this psmc file.
nice ${PSMC}/utils/psmc_plot.pl -u ${MUTRATE} -g ${GEN} -s 10 -RM "" ${OUTDIR}/${ID}_${MUT2}_t${t}_psmc.out ${OUTDIR}/${ID}_${MUT2}_t${t}.psmc

