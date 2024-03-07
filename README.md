Group Number : 7
Group Members : Chhavi Yadav, Nicholas Rittler

### PROJECT PROPOSAL 

A phenotype is the result of both environmental and genetic factors, and the contribution varies for different traits. In this project, we are interested in the heritability of a trait due to genetic factors. There are several methods to  estimate this, some using data from related individuals and others using data from unrelated individuals. We focus on the latter, and consider two such methods - Linear Mixed Models (LMM) and LD-Score Regression. To this end, the goal of our project is to characterize when and by how much the heritability estimates arising from these two methods differ.

We plan to use the 1000Genomes dataset as the basis for our investigation. Unfortunately, the 1000Geonomes data does not come with phenotypic observations. To overcome this challenge, we plan to simulate synthetic phenotypic observations stemming from various effect sizes. The upside of this approach is that it affords us access to useful ground-truth information, which can give insight into the efficacy of each of the methods in various settings. For example, it  might be interesting to conduct some sort of sensitivity analysis on the standard assumptions of linearity.

We plan to utilize the following tools in carrying out our comparison. For running LMMs, we will use GCTA (https://yanglab.westlake.edu.cn/software/gcta/#GWASSimulation). For LD-Score Regression, we will use the LDSC python library (https://github.com/bulik/ldsc). For LD-Score Regresssion, we will have to find the summary statistics and LD values first, and then feed them to the tool. Apart from difference in the values, we hope to see that LD-Score catches confounding in some cases while LMM doesn't. For this we might simulate data accordingly. We will be reporting the numbers and drawing QQ plots.


### EXPLANATION OF CODE

Our codebase currently contains two scripts, one for data phenotype simulation and one which executes commands relevant to the fitting of LMMs.

The script ```./pheno_sim.sh``` handles data simulation. It relies on the GCTA software. GCTA allows for the simulation of a phenotypes given a VCF of snps according to following formula: $y_j = \sum_i(w_{ij} \cdot \beta_i) + e_j$,
where $w_{ij} = (x_{ij} - 2p_i) / \sqrt{2p_i(1 - p_i)}$. Here, $j$ indexes individuals and $i$ causal snps; $x_{ij}$ is the number of reference alleles for the $i^{th}$ causal variant, $p_i$ is the frequency of the $i^{th}$ causal variant, and $\beta_i$ is the effect size. Errors $e_j$ are $0$ mean normally distributed with variance on the order of $1/h^2 - 1$, where $h \in (0, 1)$ specifies the trait heritability. ./pheno_sim.sh is built around commands of the following type:
```

./gcta64  --bfile causal_snps  \
                   --simu-qt \
                   --simu-causal-loci "trait_causal_${beta_multiple}.snplist" \
                   --simu-hsq ${h} \
                   --simu-rep 1  \
                   --out "traits_h=${h}_betamult=${beta_multiple}"

```
Here the binary files contains snps for individuals $j$,  ```simu-causal-loci``` is a text file with a column of causal snps and effect sizes $u_i$, ```simu-hsq``` specifies the heritability $h$, and ```simu-rep``` gives the number of simulations to run. The script loops over various values of effect size and heritability $h$ in order to generate a variety of regimes for investigation.

The script ```LMM_heritability.sh``` carries out fitting of LMMs, and also relyies on the GCTA software. The first command ```mlma`` produces the genetic relationship matrix. We finally estimate the heritability with the command
```
./gcta64 --reml \
                 --grm-bin "GCTAgrm_herit${herit}_beta${betamult}" \
                 --pheno "traits_h=${herit}_betamult=${betamult}.phen" \
                 --out "GCTAherit_herit${herit}_beta${betamult}"
```
for a given underlying heritability $h$ and beta multiple pair. 

As we expand our analysis to larger data sets, we will include a script for spltting the 1000 Genomes VCF into the relevant files for analysis.

### DESCRIPTION OF FILES 

```Simulations``` is a folder containing phenotype simulations from 6 causal SNPs with ```.phen``` extensioins, as well as files with ```.snplist``` extensions passed to ```--simu-causal-loci```; these specify effect sizes in the format described above. The simulation files are titled in the form ```"traits_h=${h}_betamult=${beta_multiple}```, where $h$ signifies heritability values, and "beta multiple" refers to a multiple of an underlying effect size vector $\beta$ with components on various orders of magnitude. For our simulations on 6 causal SNPs, the underlying $\beta$ used is $\beta = (1,.5, .1, .01, -.1, -.5)^T$. We considered "beta multiples" of $.01$, $1$, $2$, $5$, and $10$, and heritabilitiy values of $.01$, $.1$, $.2$, $.5$ and $.9$.  ```Simulations``` contains simulated phenotypes from all combinations of these beta multiples and hertiabilities. 

### EXPERIMENT OUTCOMES

So far we've simulated phenotypes and fit models for a small sample of around 200 individuals at 6 snps (using the VCF for eye color phenotypes from problem set 3) using the effect sizes and heritabilities described above. The heritability results generated using GCTA in the ```Results``` folder.  We report them in the scatterplot below.

![Scatter Plot](scatter_plot.pdf)


The x-axis is ground-truth heritability, which is the value we set to while simulating the phenotypes. The y-axis corresponds to the heritability value calculated using GCTA's LMM. For each ground-truth heritability we have multiple simulations (generated by changing the effect sizes using "beta multiples") leading to numerous calculated heritability values per ground truth.

We observe that error between the ground truth and calculated heritabilities is lower for high or very low values of heritabilities.

### TO DO

Firstly, we are left with the other half of the project, that is calculating heritability using LD-Score Regression. We plan to run the full experiments on a single chromosome (restricted to maf > .05). We will vary heritability and effect size in a variety of ways and report the accuracy of the estimation methods (perhaps visually as a function of the norm of the effect size vector and true underlying heritability used in the phenotype simulations). 
