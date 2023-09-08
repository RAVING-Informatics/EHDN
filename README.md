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

To compute STR profiles, you need the human reference genome that was used to generate the BAM/CRAM files. BAM/CRAM files we use were aligned to `Homo_sapiens_assembly38.fasta` (index = `Homo_sapiens_assembly38.fasta.fai`). This is available online within the [GATK Resource Bundle](https://console.cloud.google.com/storage/browser/genomics-public-data/resources/broad/hg38/v0/)or on the IRDS. Do not use BAM/CRAM files that were not aligned to this reference; the STR profiles will compute, but the pipeline will fail if you try to merge the STR profiles, and an error like that below will appear.`[error] Invalid contig name KN707896.1`

### Download Polaris Control Dataset

We use the HiSeqX Diversity Cohort from the Illumina Polaris Project of population sequencing resources. This dataset consists of 150 samples selected from the 1000 Genomes Project based on population diversity. A summary of this control dataset can be found [here](https://github.com/Illumina/Polaris/wiki/HiSeqX-Diversity-Cohort). STR profiles (generated using the aforementioned reference) of all 150 samples are available on the IRDS at `\\drive.irds.uwa.edu.au\PERKINS-LL-001\BioinformaticsResources\Diversity_EHdn0.9.0`

### Annotation

For annotations like gene names to be added to the EHDN output files, you need to [set-up this annotation step](https://github.com/Illumina/ExpansionHunterDenovo/blob/master/documentation/08_Annotation.md). The annotation procedure leverages [ANNOVAR](https://annovar.openbioinformatics.org/en/latest/user-guide/download/) and the `annotate_ehdn.sh` script in the EHDN GitHub Repository. Remember to use hg38 as the build-version.

---

## **Run**

There are a number of scripts available in this repository within the sub-directory `./scripts` to automate running EHDN. They are prefixed with the number representing the order that they should be executed. Run the following command to change their permissions:

```
$ chmod u+x *.sh

```
All the scripts require you to specify the location of the directory containing the input `.cram`/`.bam` files as the first and only input argument. Directions for how to use the scripts are specified below.
There is also a run script that will run all components of the EHdn workflow: `run-ehdn.sh`. 


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

---

## **Saving Results to IRDS**

It is important to create a copy of the EHDN results you generate so that they can be accessed by other analysts and are not lost if the Nimbus VM is lost. It's important to be conservative with what you transfer to save space. By default I save the following files:
- Each individual str profile `<sampleID>.str_profile.json`
- The annotated and sorted "locus" results for both case-control and outlier analysis:
  - `<sampleID>.CC_locus.annotated.sorted.tsv` 
  - `<sampleID>.outlier_locus.annotated.sorted.tsv`

Save the str profiles and results in respective directory for each year: `<year>_Profiles` and `<year>_Results` within `/Volumes/PERKINS-LL-001/Sequencing/STR-calling/Expansion Hunter De Novo/chiara_Nimbus/`
