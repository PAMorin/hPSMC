#!/bin/bash

# SLURM header
#SBATCH --job-name=hPSMC_sim
#SBATCH -e hPSMC_sim%j.e.txt
#SBATCH -o hPSMC_sim.log.%j.out
#SBATCH -c 2
#SBATCH -p medmem  # partitians= standard= 96G; medmem=192G; himem = 1.5TB
#SBATCH --mem=18G
#SBATCH -t 3-0
#SBATCH --array=1-3 # The total number of possible pairwise comparisons from a list of #SBATCH --ntasks=1
##########################################################################################

module load tools/gnuplot/5.4.1
module load bio/ms/201810

scriptdir=/home/pmorin/scripts/misc/
script=${scriptdir}hPSMC_quantify_split_time.py # from https://github.com/jacahill/hPSMC/tree/master
PSMC=~/programs/psmc

# Parameters:
ProjDir=/home/pmorin/projects/Pcra/hPSMC_Dsuite_June2025/hPSMC
INDIR=${ProjDir}/hPSMC_output
PSMClist=Pcra_PSMC_PreDivNe_list.csv # comma separated list of pseudodiploid pairs (e.g., ID1_ID2) and the pre-divergence Ne from the empirical hPSMC analysis. Value = 1E4*psmc value (e.g., psmc=5.2291, use 52291).
# ensure that csv file doesn't contain dos characters
dos2unix ${INDIR}/${PSMClist}

Range_lower=0					# divergence time range lower limit; default=0
Range_upper=300000				# divergence time range upper limit; default=10000000
Sim_num=7						# number of simulations to run 
THREADS=5						# number of simulations to run in parallel, 1/cpu
MUT=4.90E-10 #mutation rate (µ/site/yr)
MUT2=4.90E10_msy
# Sim_num is calculated as upper-lower/interval+1, e.g. ((300000-0)/50000)+1=7 (simulation for every 50,000yr in the range)
# Mut rate: Robinson et al. 2023 (doi 10.1126/science.abm1742, suppl. material) estimate for vaquita is 4.90E-10 sub/site/yr (from 5.83E-9 sub/site/gen, generation time = 11.9yr).
GEN=24
MUTRATE=$(echo $GEN $MUT | awk '{ printf "%.12f", $1*$2 }') # mutation rate (µ/site/yr) multiplied by generation time = µ/site/gen (used in PSMC)

#########################

# Get working psmc file based on array number
NUM=$(printf %02d ${SLURM_ARRAY_TASK_ID})

file=$(head -n ${NUM} ${INDIR}/${PSMClist} | tail -n 1)
echo ${file}

# get filename
psmcfile=$(echo "$file" | cut -d ',' -f 1)
echo "$psmcfile"

Ne=$(echo "$file" | cut -d ',' -f 2)
echo "$Ne"

# filesname format = ${species1}_${species2}_4.90E10_msy_t15.psmc
species1=`echo $psmcfile | cut -f1 -d "_"`
echo $species1
species2=`echo $psmcfile | cut -f2 -d "_"`
echo $species2

OUTDIR=${ProjDir}/${species1}_${species2}_mut${MUT}_simulations
mkdir -p ${OUTDIR}

# empirical psmc output file
emp=${species1}_${species2}_${MUT2}_t15.psmc
echo $emp

# set up python virtual environment:
source /home/pmorin/programs/python/bin/activate

# python script to write bash script to run simulations
python ${script} -H ${scriptdir} -P ${PSMC}/psmc -N ${Ne} -l ${Range_lower} -u ${Range_upper} -s ${Sim_num} -p ${THREADS} -o ${OUTDIR}/hPSMC_sim_ ${INDIR}/${emp} > ${OUTDIR}/${species1}_${species2}_simulations.sh

# execute bash file to run simulations
bash ${OUTDIR}/${species1}_${species2}_simulations.sh

#########################################################################################
# generate plot data and plot simulated hPSMC for each simulation.
cd ${OUTDIR}
for file2 in *.ms_sim.psmc 
do 
nice ${PSMC}/utils/psmc_plot.pl -u ${MUTRATE} -g ${GEN} -s 10 -RM ${species1}"_"${species2} ${OUTDIR}/${species1}_${species2}_${file2}.out ${file2}
done 

# modify plot output (.psmc.out.0.txt) files to add the time block to the data
for file in *out.0.txt 
do 
echo ${file}
ID=`echo ${file} | cut -f1 -d "."`
echo ${ID}
block=`echo ${ID} | cut -f5 -d "_"`
echo ${block}
awk '{print $1,$2,$3='${block}'}' ${file} > ${OUTDIR}/${file}.plot.me.txt  
done 

#Combine all the runs for one sample
cat ${OUTDIR}/*.plot.me.txt > ${OUTDIR}/${species1}_${species2}_mut${MUT}_simulations.combined.txt

# add empirical hpsmc output to simulations.combined.txt file
for file in ${INDIR}/${species1}_${species2}*psmc.out.0.txt
do 
echo ${file}
awk '{print $1,$2,$3="hpsmc"}' ${file} > ${OUTDIR}/${species1}_${species2}_hpsmc.plot.me.txt
done 

cat ${OUTDIR}/${species1}_${species2}_hpsmc.plot.me.txt >> ${OUTDIR}/${species1}_${species2}_mut${MUT}_simulations.combined.txt

# use R script "hPSMC_plot_combined_simulations.R"

######## determining pre-divergence Ne from hPSMC file (...psmc.0.txt)
# Select Ne from just before Ne starts to increase exponentially.
# The second column is the Ne, so in this case, I would choose 3.1562 (which is 31,562 because this column is Ne * 10,000)
# 0	2821014.18250367	0.000812	0.000000	0.000000
# 8278.79183673469	2821014.18250367	0.000872	0.000000	0.000000
# 17175.9673469388	2821014.18250367	0.000937	0.000000	0.000000
# 26735.9346938775	2821014.18250367	0.001007	0.000000	0.000000
# 37008.6530612245	3612.60805523809	0.845125	0.000006	0.000005
# 48047.4122448979	3612.60805523809	0.908152	0.000007	0.000010
# 59909.9428571428	91.2288023129252	38.638779	0.000291	0.000444
# 72656.1959183673	91.2288023129252	41.508159	0.000312	0.000429
# 86353.893877551	21.0972243537415	192.707309	0.001450	0.001776
# 101072.979591837	21.0972243537415	206.768999	0.001556	0.001889
# 116888.946938776	7.1237725170068	655.881178	0.004937	0.005975
# 133885.06122449	7.1237725170068	701.179227	0.005278	0.006448
# 152149.028571429	4.07203891156463	1308.072312	0.009846	0.011861
# 171774.106122449	4.07203891156463	1391.082228	0.010470	0.012385
# 192863.542857143	3.15623619047619	1903.928666	0.014331	0.016591
# 215525.028571429	3.15623619047619	2014.457126	0.015163	0.017029
# 239876.244897959	2.70964040816327	2476.311876	0.018639	0.020447
# 266043.755102041	2.70964040816327	2606.091630	0.019616	0.020929
# 294163.004081633	2.32234108843537	3188.943565	0.024003	0.025139
# 324378.318367347	2.32234108843537	3331.855783	0.025078	0.025800
# 356847.346938776	1.95295306122449	4118.813388	0.031002	0.031513
# 391738.840816327	1.95295306122449	4258.524180	0.032053	0.032280
# 429230.432653061	1.63821020408163	5212.435231	0.039233	0.039227
# 469518.628571429	1.63821020408163	5311.529163	0.039979	0.039816
# 512812.146938775	1.39657428571429	6291.959792	0.047359	0.046964
# 559333.028571428	1.39657428571429	6292.039817	0.047359	0.046915
# 609323.297959184	1.22616258503401	7089.267038	0.053360	0.052721
# 663041.632653061	1.22616258503401	6930.521266	0.052165	0.051542
# 720765.583673469	1.11667333333333	7350.033131	0.055323	0.054555
# 782794.906122449	1.11667333333333	7005.757832	0.052731	0.051997
# 849449.33877551	1.05706925170068	6965.695936	0.052430	0.051601
# 921075.265306122	1.05706925170068	6466.851060	0.048675	0.047866
# 998042.383673469	1.03951646258503	6030.873387	0.045394	0.044537
# 1080748.14693878	1.03951646258503	5458.282662	0.041084	0.040223
# 1169622.20408163	1.06056639455782	4789.278552	0.036048	0.035188
# etc.
