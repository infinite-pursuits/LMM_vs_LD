#!/bin/bash

source activate ldsc
betamults=('.01' '.1' '1' '2' '5' '10')
herits=('.01' '.1' '.2' '.5' '.9')

PREFIX=/home/cyadav/teams/heritability-project/gcta64
STUDYSNPSFOLDER=/home/cyadav/teams/heritability-project/gcta64/study_snps_folder
PHENOTYPEFOLDER=/home/cyadav/teams/heritability-project/gcta64/pheno_data
LDOUTPUTFOLDER=/home/cyadav/teams/heritability-project/gcta64/ld_output

./gcta64 --bfile $STUDYSNPSFOLDER/study_SNPs --ld-score --ld-wind 1000 --ld-rsq-cutoff 0.01 --out test_ld

awk 'NR==1 {print "CHR\tSNP\tBP\tCM\tMAF\tLD"} NR>1 {print $2 "\t" $1 "\t" $3 "\t0\t" $4 "\t" $8}' test_ld.score.ld > $PREFIX/output_file.l2.ldscore

awk 'NR > 1 && $5 > 0.05 {count++} END {print count}' $PREFIX/output_file.l2.ldscore > $PREFIX/output_file.l2.M_5_50

N=$(wc -l < $STUDYSNPSFOLDER/study_SNPs.fam)

echo "A2" > a2_alleles.txt
awk '{print $6}' $STUDYSNPSFOLDER/study_SNPs.bim >> a2_alleles.txt
        
        
for herit in "${herits[@]}"; do
    for betamult in "${betamults[@]}"; do    
        
        plink --bfile $STUDYSNPSFOLDER/study_SNPs --linear --maf 0.05 --out  $LDOUTPUTFOLDER/gwas_out_study_snps_test_herit${herit}_beta${betamult} --pheno $PHENOTYPEFOLDER/traits_h=${herit}_betamult=${betamult}.phen --allow-no-sex --exclude $PREFIX/dups
            
        paste $LDOUTPUTFOLDER/gwas_out_study_snps_test_herit${herit}_beta${betamult}.assoc.linear a2_alleles.txt > $LDOUTPUTFOLDER/gwas_out_study_snps_test_herit${herit}_beta${betamult}_witha2.txt
        
        mv $LDOUTPUTFOLDER/gwas_out_study_snps_test_herit${herit}_beta${betamult}_witha2.txt $LDOUTPUTFOLDER/gwas_out_study_snps_test_herit${herit}_beta${betamult}_witha2.assoc.linear
        
        ./ldsc/munge_sumstats.py --sumstats $LDOUTPUTFOLDER/gwas_out_study_snps_test_herit${herit}_beta${betamult}_witha2.assoc.linear --N $N --out $LDOUTPUTFOLDER/munge_stats_test_herit${herit}_beta${betamult}
        
        ./ldsc/ldsc.py --h2 $LDOUTPUTFOLDER/munge_stats_test_herit${herit}_beta${betamult}.sumstats.gz --w-ld output_file --ref-ld output_file --out $LDOUTPUTFOLDER/munge_stats_test_herit${herit}_beta${betamult}_scz_h2
        
    done
done