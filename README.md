# Expansion Hunter DeNovo (EHDN) Documentation

---

## **External Documentation**

**[EHDN paper](https://genomebiology.biomedcentral.com/articles/10.1186/s13059-020-02017-z)**

**[EHDN documentation](https://github.com/Illumina/ExpansionHunterDenovo/blob/master/documentation/00_Introduction.md)**

**[EHDN code](https://github.com/Illumina/ExpansionHunterDenovo)**

---

## **Environment / Compute**

Pawsey Nimbus Instance: 16 CPU, 64 GB RAM, Ubuntu 18.04

---

## **Installation**
You can clone this repository which contains all the necessary executables and scripts for runnign ExpansionHunter Denovo using:

```
$ git clone https://github.com/RAVING-Informatics/EHDN.git
```
If there are issues with the installation after cloning the repository you can refer to the documentation on the GitHub repository for ExpansionHunter Denovo. The Documentation provides the option to build from source, or download the [pre-compiled binaries from GitHub](https://github.com/Illumina/ExpansionHunterDenovo/releases) (which I did):

```
$ wget https://github.com/Illumina/ExpansionHunterDenovo/releases/download/v0.9.0/ExpansionHunterDenovo-v0.9.0-linux_x86_64.tar.gz
$ tar xzvf ExpansionHunterDenovo-v0.9.0-linux_x86_64.tar.gz
```

Also good to add the executable to the PATH. Do this by adding the following line of code to the .bashrc file in your home directory:

`export PATH=<path_to_ehdn_working_directory>/bin:$PATH`

---

## **Preparation**

### Make Directory Structure

Note, if you have cloned this repository you shouldn't need to make the result directories.


**input directories**

input file type = `.bam or .cram`

```
$ mkdir /data/preprocessed/bams-str
```

**result directories**

```
$ mkdir <path_to_ehdn_working_directory>/str-profiles
$ mkdir <path_to_ehdn_working_directory>/results
```

### Download Reference Sequence

To compute STR profiles, you need the human reference genome that was used to generate the BAM/CRAM files. Our BAM/CRAM files we use were aligned to `Homo_sapiens_assembly38.fasta` (index = `Homo_sapiens_assembly38.fasta.fai`). This is available online within the [GATK Resource Bundle](https://console.cloud.google.com/storage/browser/genomics-public-data/resources/broad/hg38/v0/) or on the IRDS. Do not use BAM/CRAM files that were not aligned to this reference; the STR profiles will compute, but the pipeline will fail if you try to merge the STR profiles, and an error like that below will appear.`[error] Invalid contig name KN707896.1`

### Download Polaris Control Dataset

We use the HiSeqX Diversity Cohort from the Illumina Polaris Project of population sequencing resources. This dataset consists of 150 samples selected from the 1000 Genomes Project based on population diversity. A summary of this control dataset can be found [here](https://github.com/Illumina/Polaris/wiki/HiSeqX-Diversity-Cohort). STR profiles (generated using the aforementioned reference) of all 150 samples are available on the IRDS at `\\drive.irds.uwa.edu.au\PERKINS-LL-001\BioinformaticsResources\Diversity_EHdn0.9.0`

### Annotation

For annotations like gene names to be added to the EHDN output files, you need to [set-up this annotation step](https://github.com/Illumina/ExpansionHunterDenovo/blob/master/documentation/08_Annotation.md). The annotation procedure leverages [ANNOVAR](https://annovar.openbioinformatics.org/en/latest/user-guide/download/) and the `annotate_ehdn.sh` script in the EHDN GitHub Repository. The script will already be available in the `scripts/` directory in this repository, but you will need to download and set up `ANNOVAR`. Remember to use hg38 as the build-version.

---

## **Run**

There are a number of scripts available in this repository within the sub-directory `./scripts` to automate running EHDN. They are prefixed with the number representing the order that they should be executed. Run the following command to change their permissions:

```
$ chmod u+x *.sh
```
All the scripts require you to specify the location of the directory containing the input `.cram`/`.bam` files as the first and only input argument. Make sure to also edit the path to the working directory and the reference genome in each script. Details of what each script does are provided below:

There is also a run script that will run all components of the EHdn workflow: `run-ehdn.sh`. 

Example command to execute this script:

```
$ ./run-ehdn.sh /data/preprocessed/bams-str
```

### *1) Generate Per Sample Manifest*

The `01_make_manifest.sh` script modifies an existing template manifest `manifest.txt` by changing the "`basename`" of the `case` data. All of the other data in the manifest is the `control` data from the `Diversity` dataset. The script will output a `basename_manifest.txt` file to `<path_to_ehdn_working_directory>/manifests/`. This file is required to merge the STR profiles and perform outlier analysis.

Example command to execute this script:

```
$ ./01_make-manifest.sh /data/preprocessed/bams-str
```

### *2) Generate STR profiles*

`02_compute-str.sh` script will output an STR profile in `.json` format to `<path_to_ehdn_working_directory>/str-profiles`

Example command to execute this script:

```
$ ./02_compute-str.sh /data/preprocessed/bams-str
```

### *3) Merge STR profiles*

The `03_merge-profile.sh` script will generate a multisample STR profile by merging the STR profiles of the single `case` sample with that of the Diversity `controls`. The output file (`basename.multisample_profile.json`) is written into a sub-directory of the `str-profiles/` directory (`str-profiles/merged/`).

Example command to execute this script:

```
$ ./merge-profile.sh /data/preprocessed/bams-str
```

### *4) Run case-control analysis*

The `05_case-control-analysis.sh` script will locus analysis on the multisample STR profile generated in step 3). The results of this analysis will be output to the `results/` subdirectory of the workspace directory: `basename.case-control_locus.tsv`.

Example command to execute this script:

```
$ ./05_case-control-analysis.sh /data/preprocessed/bams-str
```

### *5) Run outlier analysis*

The `05_outlier-analysis.sh` script will run locus analysis on the multisample STR profile generated in step 3). The results of this analysis will be output to the `results/` subdirectory of the workspace directory: `basename.outlier_locus.tsv`.

Example command to execute this script:

```
$ ./05_outlier-analysis.sh /data/preprocessed/bams-str
```

### *06) Annotate results*

The initial result tsv files generated are not annotated to contain information about the gene and genomic region for each repeat locus identified. This can be done using the `06_annotate-results.sh` script. The annotated files are output to the same `results/` directory as the original result files from outlier analysis.

Example command to execute this script:

```
$ ./annotate-results.sh /data/preprocessed/bams-str
```
In order to run this script you will need to set up `annovar`. Instructions for setting up `annovar` are available [here](https://github.com/Illumina/ExpansionHunterDenovo/blob/master/documentation/08_Annotation.md)

---

## **Post-processing**

Once you have generated all your desired results, you can run two post-processing scripts that will add further annotation to the result files.

1. The first was written by Ben Weisburd and is available in his [str-analysis repository](https://github.com/broadinstitute/str-analysis/blob/main/str_analysis/annotate_EHdn_locus_outliers.py). There is a copy of this script, alongside a run script (`run-bw-script.sh`) in the `./scripts` directory in this repository, however it may be worth downloading a more recent version in case there are updates. I run both the case-control and outlier result directories through this script.

```bash
$ ./run-bw-script.sh <path-to-results-directory>
```

2. The second is an extra post-processing script for `outlier` analysis that includes a python script I made with the help of chatGPT `gene-counts.py` and a script leveraging `bedtools intersect`. `gene-counts.py` counts the total number of occurrences of each gene in every result tsv file within a batch, then adds a new column to each tsv with the count data. `bedtools intersect` determines how many times a given co-ordinate called in a sample intersects with the co-ordinates in the outputs from the rest of the samples. I use this to see how many times the gene / repeat is being called across the cohort, with the assumption that if it is common it is likely to be a false positive call or an artefact. I would recommend running this only on the `outlier` results (after running Ben’s script).

Note, this script requires a `header.tsv` file containing a copy of the header of the original results file plus two extra column headers for the new count data, i.e:
```
contig	start	end	motif	gene	region	top_case_zscore	gene_count	Source	MotifSize	CanonicalMotif	MatchedKnownDiseaseAssociatedLocus	MatchedKnownDiseaseAssociatedMotif	MatchedReferenceTR	SampleId	NormalizedCount	SampleRankAtLocus	TotalSamplesAtLocus	interval_count
```

```bash
$ ./outlier-postprocess.sh <path-to-results-directory>
```

# Result Interpretation and Filtering

## Case-control results

- Ben’s postprocessing script will generate a separate entry for each sample in the merged str-profile (i.e. the sample of interest vs the Diversity dataset). You want to restrict the view to just the result for the sample of interest.
    - Filter: `SampleId = <sample_of_interest>`
- Ben’s postprocessing script will also provide the rank of your sample. Filter the results so that the sample ranks in the top ~10 and rank them in order of increasing sample rank.
    - Filter: `SampleRank = <10`
- Sort the results by increasing p-value.
- Give priority to expansion calls that overlap matched known disease associated loci and matched reference TRs.

## Outlier

- Rank in order of highest z-score.
- Ignore the SampleRankAtLocus and TotalSamplesAtLocus
- Pay attention to the number value of the `gene_count` and `interval_count`. These will indicate how many times an expansion in that gene/locus has appeared across the entire cohort.
    - `gene_count` is computed using the `[gene-counts.py](http://gene-counts.py)` python script.
    - `interval_count` is computed using `bedtools`.
 
## **Saving Results to IRDS**

It is important to create a copy of the EHDN results you generate so that they can be accessed by other analysts and are not lost if the Nimbus VM is lost. It's important to be conservative with what you transfer to save space. By default I save the following files:
- Each individual str profile `<sampleID>.str_profile.json`
- The annotated and sorted "locus" results for both case-control and outlier analysis:
  - `<sampleID>.CC_locus.annotated.sorted.tsv` 
  - `<sampleID>.outlier_locus.annotated.sorted.tsv`

Save the str profiles and results in respective directory for each year: `<year>_Profiles` and `<year>_Results` within `/Volumes/PERKINS-LL-001/Sequencing/STR-calling/Expansion Hunter De Novo/chiara_Nimbus/`
