# hybrid-PSMC (hPSMC)
Implementation of hPSMC scripts for SLURM scheduler on linux cluster, based on Cahill et al. 2016 (doi: 10.1098/rstb.2015.0138)

Description
:
This repository describes a pipeline for conducting hybrid PSMC analysis (hPSMC) as described by Cahill et al. (2016), available in the Github repository https://github.com/jacahill/hPSMC. It includes scripts from that publication, and additional bash scripts developed to facilitate running the hPSMSC pipeline scripts in a SLURM scheduler on a Linux cluster. 

If you are using these scripts, please cite the following papers.

Cahill, J.A., Soares, A.E., Green, R.E., Shapiro, B., 2016. Inferring species divergence times using pairwise sequential Markovian coalescent modelling and low-coverage genomic data. Philos Trans R Soc Lond B Biol Sci 371.



1. Generate consensus sequences

2. Generate pseudo-hybrid sequence files (hpsmcfa)

3. Run PSMC on pseudo-hybrid sequences

4. Simulate hPSMC to estimate confidence intervals for divergence time


