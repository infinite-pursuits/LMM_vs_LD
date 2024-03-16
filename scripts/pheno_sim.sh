#!/bin/bash

########### SIMULATION OF PHENOTYPES ###############
# Usage: 1) navigate to ~/private/gcta64/ 2) ./pheno_sim.sh
# Note: to get execution permission: chmod +x pheno_sim.sh
# Assumes existance of trait_causal.snplist containing snps and effect sizes


### first, extract SNPs for a subset of population 

plink   --vcf ~/public/ps3/ps3_pred_eyecolor.vcf.gz \
        --out causal_snps \
        --make-bed
 
### simulate for a variety of beta multiples, hertiability 

for beta_multiple in .01 1  # mutlitples of original effect sizes
do
    for h in .001 .1  # can add more; heritability
    do
         ./gcta64  --bfile causal_snps  \
                   --simu-qt \
                   --simu-causal-loci "trait_causal_${beta_multiple}.snplist" \
                   --simu-hsq ${h} \
                   --simu-rep 1  \
                   --out "traits_h=${h}_betamult=${beta_multiple}"
    done
done

