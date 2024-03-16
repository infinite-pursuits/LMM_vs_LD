#!/bin/bash

########### SIMULATION OF PHENOTYPES ###############
# Usage: 1) navigate to ~/private/gcta64/ 2) ./pheno_sim.sh
# Note: to get execution permission: chmod +x pheno_sim.sh
# Assumes existance of trait_causal.snplist containing snps and effect sizes

 
### simulate for a variety of beta multiples, hertiability 

PHENOFOLDER=/home/cyadav/teams/heritability-project/gcta64/pheno_data
STUDYSNPSFOLDER=/home/cyadav/teams/heritability-project/gcta64/study_snps_folder


for beta_multiple in .01 .1 1 2 5 10   # mutlitples of original effect sizes .01 .1 1 2 5 10 
do
    for h in .01 .1 .2 .5 .9 # can add more; heritability .01 .1 .2 .5 .9
    do
         
         # create a temp file with beta_multiple * original effect to use for the simulation
         awk -v m=${beta_multiple} '{$2=$2*m; print $0}' $STUDYSNPSFOLDER/causal_SNPs.snplist > $STUDYSNPSFOLDER/temp.snplist 
         
         ./gcta64  --bfile $STUDYSNPSFOLDER/study_SNPs  \
                   --simu-qt \
                   --simu-causal-loci $STUDYSNPSFOLDER/temp.snplist \
                   --simu-hsq ${h} \
                   --simu-rep 1  \
                   --out $PHENOFOLDER/traits_h=${h}_betamult=${beta_multiple}
    done
done

