# hybrid-PSMC (hPSMC)
Implementation of hPSMC scripts for SLURM scheduler on linux cluster, based on Cahill et al. 2016 (doi: 10.1098/rstb.2015.0138)

# Description
:
This repository describes a pipeline for conducting hybrid PSMC analysis (hPSMC) as described by Cahill et al. (2016), available in the Github repository https://github.com/jacahill/hPSMC. It includes scripts from that publication, and additional bash scripts developed to facilitate running the hPSMSC pipeline scripts in a SLURM scheduler on a Linux cluster. 

If you are using these scripts, please cite the following papers.

Cahill, J.A., Soares, A.E., Green, R.E., Shapiro, B., 2016. Inferring species divergence times using pairwise sequential Markovian coalescent modelling and low-coverage genomic data. Philos Trans R Soc Lond B Biol Sci 371.


# Getting Started

## Dependencies
Before running the pipeline, make sure you have installed the following programs:

angsd v0.940 





## 1. Generate consensus sequences

Methods described on github.com/jacahill/hpsmc use the program "pu2fa" to genearte haploidized consensus chromosome sequences from a bam pileup file, using very high base quality threshold (-Q60) to "minimize the inpact of sequencing error". Here, I use the program angsd to generate the haploid consensus genome, including only specified chromosomes, and less stringent mapping and base quality thresholds (-minQ 25 -minmapq 25). 

Input:
bamlist.txt: a text file listing the path and filename for each sample or species bam file to be used for generating pseudo-hybrid genomes. 
Chromosome IDs: the scaffold IDs that correspond to autosomes in a chromosome-resolved reference genome that was used as the reference for mapping reads from all of the samples/species to be used for generating pseudo-hybrid genomes.

sbatch 1.hPSMC_consensus_genomes_array_sedna.sh

Output:
Haploid consensus genome fasta files for each sample/species genome bam file. 


2. Generate pseudo-hybrid sequence files (hpsmcfa)


3. Run PSMC on pseudo-hybrid sequences

4. Simulate hPSMC to estimate confidence intervals for divergence time


