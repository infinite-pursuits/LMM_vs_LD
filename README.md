Group Number : 7
Group Members : Chhavi Yadav, Nicholas Rittler

### PROJECT PROPOSAL 

A phenotype is the result of both environmental and genetic factors, and the contribution varies for different traits. In this project, we are interested in the heritability of a trait due to genetic factors. There are several methods to  estimate this, some using data from related individuals and others using data from unrelated individuals. We focus on the latter, and consider two such methods - Linear Mixed Models (LMM) and LD-Score Regression. To this end, the goal of our project is to characterize when and by how much the heritability estimates arising from these two methods differ.

We plan to use the 1000Genomes dataset as the basis for our investigation. Unfortunately, the 1000Geonomes data does not come with phenotypic observations. To overcome this challenge, we plan to simulate synthetic phenotypic observations stemming from various effect sizes. The upside of this approach is that it affords us access to useful ground-truth information, which can give insight into the efficacy of each of the methods in various settings. For example, it  might be interesting to conduct some sort of sensitivity analysis on the standard assumptions of linearity.

We plan to utilize the following tools in carrying out our comparison. For running LMMs, we will use GCTA (https://yanglab.westlake.edu.cn/software/gcta/#GWASSimulation). For LD-Score Regression, we will use the LDSC python library (https://github.com/bulik/ldsc). For LD-Score Regresssion, we will have to find the summary statistics and LD values first, and then feed them to the tool.


### EXPLANATION OF REPO

```libraries.yml``` : All the libraries needed to run our code.

```scripts``` : All the scripts to run the the code. The paths mentioned on the top of the scripts have to be changed according to your convenience. To generate phenotypes, run ```preprocessing.sh``` followed by ```pheno_sim.sh```. To run LMM, use  ```LMM_heritability.sh``` while for LD-Score Regression, run ```ld_score_reg.sh```.

The phenotype data we used is present in ```pheno_data``` folder.  The outputs from running the LMM and LDSC scripts are present in ```lmm_output``` and ```ld_output``` folders respectively. The final plots are available in the ```plots``` folder while the code to generate those plots is present in the ```plotting_ntbks``` folder. ```Conjecture_LMM``` has data and results for the additional experiments/ablations we did with LMMs. ```covars_pca``` has the PCA results. ```dups``` has duplicate SNPs that need to removed, sometimes the LD scores code causes problems due to duplicate SNPs.


The script ```./pheno_sim.sh``` handles data simulation which is built around commands of the following type:
```

./gcta64  --bfile /path/to/causal_snps  \
                   --simu-qt \
                   --simu-causal-loci \path\causalsnps\effectsizes \
                   --simu-hsq ${h} \
                   --simu-rep 1  \
                   --out \path\to\output

```
Here the binary files contains snps for individuals $j$,  ```simu-causal-loci``` is a text file with a column of causal snps and effect sizes, ```simu-hsq``` specifies the heritability $h$, and ```simu-rep``` gives the number of simulations to run. The script loops over various values of effect size and heritability $h$ in order to generate a variety of regimes for investigation.

The script ```LMM_heritability.sh``` carries out fitting of LMMs, and also relyies on the GCTA software. The first command ```--make-grm``` produces the genetic relationship matrix. We finally estimate the heritability with the command
```
./gcta64 --grm  /path/to/GRM/ \
                 --pheno /path/to/phenotypes \
                 --reml \
                 --out /path/to/output \
                 --qcovar /path/to/pca/covariates
```
for a given underlying heritability $h$ and beta multiple pair.

The script ```ld_reg_score.sh``` runs the LD score regression model via the LDSC library. The main command is
```
./ldsc/ldsc.py --h2 /path/to/summary/stats \
               --w-ld /path/to/ld/scores \
               --ref-ld /path/to/ref/ld/scores \
               --out /path/to/output

```
where we input the summary statistics (in the format mentioned 
As we expand our analysis to larger data sets, we will include a script for spltting the 1000 Genomes VCF into the relevant files for analysis.

### EXPERIMENT OUTCOMES

The final experimental results can be visualized in the ```plots``` folder. The report is available in the file ```report.pdf``` . Overall we find that both methods underestimate the heritability -- this could be due to the simulation construction. LMM tends to be more reliable than LDSC -- this might come from a compounding of errors accumulated from GWAS summary statistics and LD scores which have to calculated for the regression. See the report for more detailed discussion.
