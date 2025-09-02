# hybrid-PSMC (hPSMC)
Implementation of hPSMC scripts for SLURM scheduler on linux cluster, based on Cahill et al. 2016 (doi: 10.1098/rstb.2015.0138)

# Description

This repository describes a pipeline for conducting hybrid PSMC analysis (hPSMC) as described by Cahill et al. (2016), available in the Github repository https://github.com/jacahill/hPSMC. It includes scripts from that publication, and additional bash scripts developed to facilitate running the hPSMSC pipeline scripts in a SLURM scheduler on a Linux cluster. 

If you are using these scripts, please cite the following papers.

Cahill, J.A., Soares, A.E., Green, R.E., Shapiro, B., 2016. Inferring species divergence times using pairwise sequential Markovian coalescent modelling and low-coverage genomic data. Philos Trans R Soc Lond B Biol Sci 371.

Li, H., Durbin, R., 2011. Inference of human population history from individual whole-genome sequences. Nature 475, 493-496.

Hudson RR, 2002. Generating samples under a Wright-Fisher neutral model of genetic variation., Bioinformatics, 18:337-8

# Getting Started

## Dependencies
Before running the pipeline, make sure you have installed the following programs:

angsd v0.940

samtools v1.11

bcftools v1.11

gnuplot v5.4.1

psmc (from https://github.com/lh3/psmc)

ms (Hudson, R. R. (2002), https://home.uchicago.edu/~rhudson1/source/mksamples.html)

R version 4.4.3

From https://github.com/jacahill/hPSMC/tree/master:

psmcfa_from_2_fastas.py

hPSMC_quantify_split_time.py


## 1. Generate consensus sequences

Methods described on github.com/jacahill/hpsmc use the program "pu2fa" to genearte haploidized consensus chromosome sequences from a bam pileup file, using very high base quality threshold (-Q60) to "minimize the inpact of sequencing error". Here, I use the program angsd to generate the haploid consensus genome, including only specified chromosomes, and less stringent mapping and base quality thresholds (-minQ 25 -minmapq 25). 

Input:
bamlist.txt: a text file listing the path and filename for each sample or species bam file to be used for generating pseudo-hybrid genomes. File names should start with format "${sp}\_${ID}", where sp=(species ID) and ID=(sample ID), separated by "\_". 


Chromosome IDs: the scaffold IDs that correspond to autosomes in a chromosome-resolved reference genome that was used as the reference for mapping reads from all of the samples/species to be used for generating pseudo-hybrid genomes.

`sbatch 1.hPSMC_consensus_genomes_array_sedna.sh`

Output:
New subdirectory containing haploid consensus genome fasta files for each sample/species genome bam file. File names will start with format "${sp}\_${ID}", where sp=(species ID) and ID=(sample ID), separated by "\_". 


## 2. Generate pseudo-hybrid sequence files (hpsmcfa)

Input: 
consensus_autosome_genomes_list.txt: a text file listing the names of the haploid consensus genomes generated in step 1, all in one directory.

`sbatch 2.Pcra_psmcfa_sedna.sh`

(this script calls the python script 'psmcfa_from_2_fastas.py')

Output: 
New subdirectory containing pseudo-hybrid 'psmcfa' files for each species/sample pair.


## 3. Run PSMC on pseudo-hybrid (psmcfa) sequences. PSMC uses default settings from Li and Durban, 2011, except for the mutation rate and generation times appropriate to the target species. 

Input:
psmcfa_files.txt: a text file with the list of psmcfa files from step 2, all in one directory.
Genome-wide mutation rate (substitutions/site/year)
Generation length to be used for scaling hPSMC plots. This should be an estimated average for the species being compared.

`sbatch 3.hPSMC_array_sedna.sh`

Output:
standard psmc output files for each pseudo-hybrid pair:

psmc - the psmc output file

psmc.out.gp - gnuplot input file for plotting psmc results

psmc.out.eps - rendered plot of the psmc results (Encapsulated PostScript format)

psmc.out.0.txt - summary output for psmc (used to determine the pre-divergence Ne in next step).

<p align="center">
  <img src="/image/Barn_Bmin_9.10E10_msy_t15_psmc.out.png" alt="Drawing" width="250"/>
</p>

## 4. Simulate hPSMC using ms coalescent simulator to estimate confidence intervals for divergence time

Input:
Genome-wide mutation rate (substitutions/site/year). Use the same rate as used in step 3.
Generation length to be used for scaling hPSMC plots. This should be an estimated average for the species being compared. Use the same generation length as used in step 3.
Simulation number and time range (e.g., 100,000 - 1,000,000 years in 100,000 year increments)
PSMC_PreDivNe_list.csv: CSV file containing column of sample/species pairs (matching output file format from step 3) and the estimated pre-divergence Ne value for each pair.

### Get the estimated pre-divergence Ne for each pair from the step 3 output file "...psmc.out.0.txt". The third column in the file represents Ne/10,000. Select a value that immediately precedes the rapid increase in the top lines of the file, representing the onset of divergence. 

![screenshot] (https://github.com/PAMorin/hPSMC/tree/main/images/example_psmc.out.0.txt.png)

`sbatch 4.hPSMC_split_simulations_array_sedna.sh`

(This bash script calls python script "hPSMC_quantify_split_time.py")

Output:
Directories for each simulated pair, containing simulation files, including combined simulation and empirical data derived hPSMC output, "...simulations.combined.txt" for use in plotting results.


## 5. plot combined hPSMC and simulated hPSMC results to identify divergence time confidence interval.

Input:
<species_names>_simulations.combined.txt (one file for each pair of species)

In R script "hPSMC_plot_combined_simulations.R", Enter the species (or sample) names as they appear in the simulations.combined.txt file, and the pre-divergence Ne that was used for the simulations for the species pair. 

The "simulations.combined" object should be modified if needed to match the name of the input simulations.combined.txt file.

In the "Simulated and empirical data plot" section of the script, the number of lines should match the number of simulations (plus one at the top for the empirical data). For example, if there were 10 simulations, the lines for all 'hpsmcNo" from 11 to 30 should be commented out, leaving the first line "dataset$X3==hpsmc", and the bottom 10 lines. 

Run the entire script to generate the pdf file of the simulated data plot, and look at the plot to determine where the confidence interval lines should be. Select lines that do not overlap the empirical data line in the section between the two red horizontal dashed lines. Change the alpha values for the selected confidence interval lines from 0.9 to 1.0 to change their color from gray to black, and re-run the script to generate a new plot with the selected confidence interval lines. 

![screenshot] (https://github.com/PAMorin/hPSMC/tree/main/images/Bbai_Bmin_sim_plot.png)









