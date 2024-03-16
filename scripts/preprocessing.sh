#############################################################
### main preprocessing script
#############################################################

# paths to relevant raw data 
VCF=~/public/1000Genomes/ALL.chr21.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz
SAMPLEINFO=~/public/1000Genomes/igsr_samples.tsv

# extract samples from populations included in study GBR PJL
cat ~/public/1000Genomes/igsr_samples.tsv | \
  grep "1000 Genomes phase 3 release" | \
  awk -F"\t" '($4=="CEU" || $4=="PEL" || $4=="YRI" || $4=="FIN" || $4=="PUR" || $4=="CHS" || $4=="PJL" || $4=="GBR")' | \
  awk '{print $1 "\t" $1}' > individuals.txt


# write binary, restricted to locations with maf > .1, keep only samples extracted above (--keep <sample list> --double-id)
# output a binary plink format (--make-bed)
PREFIX=~/teams/heritability-project/gcta64/study_snps_folder
PCAPREFIX=~/teams/heritability-project/gcta64/covars_pca

plink --vcf $VCF --maf 0.1 --keep individuals.txt --double-id --make-bed --out $PREFIX/study_SNPs


# run PCA, k=4
plink --pca 3 --bfile $PREFIX/study_SNPs --out $PCAPREFIX/pca_covars --allow-no-sex 

# rename file of projections onto top k PCs to conform with GCTA software 
mv $PCAPREFIX/pca_covars.eigenvec $PCAPREFIX/pca_covars.qcovar
