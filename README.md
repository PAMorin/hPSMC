# hybrid-PSMC (hPSMC)
Implementation of hPSMC scripts for SLURM scheduler on linux cluster, based on Cahill et al. 2016 (doi: 10.1098/rstb.2015.0138)

# Description

This repository describes a pipeline for conducting hybrid PSMC analysis (hPSMC) as described by Cahill et al. (2016), available in the Github repository https://github.com/jacahill/hPSMC. It includes scripts from that publication, and additional bash scripts developed to facilitate running the hPSMSC pipeline scripts in a SLURM scheduler on a Linux cluster. 

If you are using these scripts, please cite the following papers.

Cahill, J.A., Soares, A.E., Green, R.E., Shapiro, B., 2016. Inferring species divergence times using pairwise sequential Markovian coalescent modelling and low-coverage genomic data. Philos Trans R Soc Lond B Biol Sci 371.

Li, H., Durbin, R., 2011. Inference of human population history from individual whole-genome sequences. Nature 475, 493-496.

# Getting Started

## Dependencies
Before running the pipeline, make sure you have installed the following programs:

angsd v0.940

samtools v1.11

bcftools v1.11

gnuplot v5.4.1

psmc (from https://github.com/lh3/psmc)

From https://github.com/jacahill/hPSMC/tree/master:
psmcfa_from_2_fastas.py


## 1. Generate consensus sequences

Methods described on github.com/jacahill/hpsmc use the program "pu2fa" to genearte haploidized consensus chromosome sequences from a bam pileup file, using very high base quality threshold (-Q60) to "minimize the inpact of sequencing error". Here, I use the program angsd to generate the haploid consensus genome, including only specified chromosomes, and less stringent mapping and base quality thresholds (-minQ 25 -minmapq 25). 

Input:
bamlist.txt: a text file listing the path and filename for each sample or species bam file to be used for generating pseudo-hybrid genomes. File names should start with format "${sp}_${ID}", where sp=(species ID) and ID=(sample ID), separated by "_". 


Chromosome IDs: the scaffold IDs that correspond to autosomes in a chromosome-resolved reference genome that was used as the reference for mapping reads from all of the samples/species to be used for generating pseudo-hybrid genomes.

sbatch 1.hPSMC_consensus_genomes_array_sedna.sh

Output:
New subdirectory containing haploid consensus genome fasta files for each sample/species genome bam file. File names will start with format "${sp}_${ID}", where sp=(species ID) and ID=(sample ID), separated by "_". 


## 2. Generate pseudo-hybrid sequence files (hpsmcfa)

Input: 
consensus_autosome_genomes_list.txt: a text file listing the names of the haploid consensus genomes generated in step 1, all in one directory.

sbatch 2.Pcra_psmcfa_sedna.sh

(this script calls the python script 'psmcfa_from_2_fastas.py')

Output: 
New subdirectory containing pseudo-hybrid 'psmcfa' files for each species/sample pair.


## 3. Run PSMC on pseudo-hybrid (psmcfa) sequences. PSMC uses default settings from Li and Durban, 2011, except for the mutation rate and generation times appropriate to the target species. 

Input:
psmcfa_files.txt: a text file with the list of psmcfa files from step 2, all in one directory.
Genome-wide mutation rate (substitutions/site/year)
Generation length to be used for scaling hPSMC plots. This should be an estimated average for the species being compared.

sbatch 3.hPSMC_array_sedna.sh

Output:
standard psmc output files for each pseudo-hybrid pair:

psmc - the psmc output file

psmc.out.gp - gnuplot input file for plotting psmc results

psmc.out.eps - rendered plot of the psmc results (Encapsulated PostScript format)

psmc.out.0.txt - summary output for psmc (used to determine the pre-divergence Ne in next step).


## 4. Simulate hPSMC to estimate confidence intervals for divergence time



## 5. plot combined hPSMC and simulated hPSMC results to identify divergence time confidence interval.




