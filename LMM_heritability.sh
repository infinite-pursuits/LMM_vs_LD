#!/bin/bash

betamults=('.01' '1')
herits=('.001' '.1')

for herit in "${herits[@]}"; do
    for betamult in "${betamults[@]}"; do
        # Run GCTA MLMA
        ./gcta64 --mlma \
                 --bfile ~/teams/heritability-project/gcta64/causal_snps \
                 --pheno "traits_h=${herit}_betamult=${betamult}.phen" \
                 --out "GCTAresults_herit${herit}_beta${betamult}"

        # Run GCTA to generate genetic relationship matrix (GRM)
        ./gcta64 --bfile ~/teams/heritability-project/gcta64/causal_snps \
                 --autosome --make-grm-bin \
                 --out "GCTAgrm_herit${herit}_beta${betamult}"

        # Run GCTA REML
        ./gcta64 --reml \
                 --grm-bin "GCTAgrm_herit${herit}_beta${betamult}" \
                 --pheno "traits_h=${herit}_betamult=${betamult}.phen" \
                 --out "GCTAherit_herit${herit}_beta${betamult}"

    done
done

