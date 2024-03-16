#!/bin/bash

betamults=('.01' '.1' '1' '2' '5' '10')
herits=('.01' '.1' '.2' '.5' '.9')
# betamults=('1')
# herits=('.5')

PHENODATA=/home/cyadav/teams/heritability-project/gcta64/pheno_data
LMMOUT=/home/cyadav/teams/heritability-project/gcta64/lmm_output
STUDYSNPSFOLDER=/home/cyadav/teams/heritability-project/gcta64/study_snps_folder
PCAFOLDER=/home/cyadav/teams/heritability-project/gcta64/covars_pca

# with PC controls
for herit in "${herits[@]}"; do
    for betamult in "${betamults[@]}"; do
        
    
        # get GRM
        ./gcta64 --bfile $STUDYSNPSFOLDER/study_SNPs --make-grm --out $LMMOUT/GCTAgrm_herit${herit}_beta${betamult}

        # run REML
        ./gcta64 --grm  $LMMOUT/GCTAgrm_herit${herit}_beta${betamult} \
                 --pheno $PHENODATA/traits_h=${herit}_betamult=${betamult}.phen \
                 --reml \
                 --out $LMMOUT/herit${herit}_beta${betamult} \
                 --qcovar $PCAFOLDER/pca_covars.qcovar \
                 --thread-num 10 

    done
done

# without controls
for herit in "${herits[@]}"; do
    for betamult in "${betamults[@]}"; do
        

        # get GRM
        ./gcta64 --bfile $STUDYSNPSFOLDER/study_SNPs --make-grm --out $LMMOUT/GCTAgrm_herit${herit}_beta${betamult}

        # run REML
        ./gcta64 --grm  $LMMOUT/GCTAgrm_herit${herit}_beta${betamult} \
                 --pheno $PHENODATA/traits_h=${herit}_betamult=${betamult}.phen \
                 --reml \
                 --out $LMMOUT/herit${herit}_beta${betamult}_no_covars \
                 --thread-num 10 

    done
done

#EXP_large