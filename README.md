# FORCE11 PREreview Club Nov 2026

This repository contains exploratory R scripts written and outputs produced as part of the Nov 2026 FORCE PREreview Club review of 

> Lawrimore J, Li C, Moraczewski D, Poline J-B, Thomas A. 2026. Who Funds Open Data Sharing? Analysis of data availability statements in biomedical publications. *bioRxiv*. DOI: https://doi.org/10.64898/2026.07.17.739022

We also explored the data and code shared by the authors in the `osm-preprint-2026` repository: 

> Thomas A. 2026. LaTeX preprint analyzing open data sharing trends in biomedical research (2024-2025). Github. https://github.com/nimh-dsst/osm-preprint-2026

Our collaborative review is shared on PREReview:

> To be added when available

*Note: PREreview author order reflects the sequence in which co-authors confirm participation.*

<br>


## Scope and Limitations

> [!IMPORTANT] 
> We wrote these exploratory R scripts and generated the accompanying outputs to inform our preprint review. This repository is not intended to serve as a reproducible analysis workflow.

We used the authors’ funder- and journal-level summaries to inspect reported results and reconstruct selected figures and tables. We consulted the authors’ code to understand how the summaries were produced. Our checks began with the shared summaries and did not cover article-level processing. The scripts retrieve the summaries from the authors’ `develop` branch, so the inputs may change over time.

<br>


## Exploratory Analysis and Findings

We mostly explored four questions using the shared summaries from the preprint reposity and the PLOS Open Science Indicators (OSI) dataset.

### 🔢 Understanding the shared summaries

We examined how the shared summary data describes funders/publishers, article counts, and data-sharing rates. For the funder data, we pulled out US and Chinese funders because they were among the most represented in the preprint's Table 1. Looking at each country separately made it easier to inspect individual funders and put their reported rates in the context of their article counts. 

### 📊 Reconstrucing results from the shared summaries

We used the published summaries to reconstruct the funder- and publisher-level results in the preprint Figures and Tables, with some differences in presentation. We also redrew Figure 2 as a lollipop plot to see whether that format made the journal-level comparison easier to read. 

### ➗ Effect of denominator on data-sharing rates in PLOS OSI

Not all research articles generate data. We were interested in exploring if accounting for data generation affects the data-sharing rates. Lawrimore et al does not account for data generation, but PLOS Open Science Indicators (OSI) dataset does. Using PLOS OSI, we compared data-sharing rates calculated across all included articles with rates restricted to articles flagged as generating data. The two data-sharing rates were close within both the PLOS and comparator datasets.

### 🆚 Comparison to between the two datasets

We compared article counts and data-sharing rates for PLOS journals across the preprint dataset and the PLOS OSI dataset. While article counts were broadly similar, the reported data-sharing rates in PLOS OSI were considerably higher. As part of this analysis, we also noticed that only roughly 35-50% of PLOS articles in the preprint dataset were clasified as PDF-covered. Additionally, the reported rates tend of be higher for PDF-covered articles than XML-only articles. 

These differences raise questions about how corpus coverage and data-sharing dection methods affect reported rates. Because we worked from the preprint's journal-level summaries, we could not determine which articles appeared in both datasets or how often the methods diagreed on the same article.

<br>


## Repository Guide

| Location | Content | 
| :--- | :--- | 
| [`code/01-preprint-data-examination.R`](code/01-preprint-data-examination.R) | Funder and journal summaries, reconstruction of selected preprint figures and tables, and inspection of coverage for PLOS journals | 
| [`code/02-PLOS-OSI-comparison.R`](code/02-PLOS-OSI-comparison.R) | PLOS OSI denominator comparison and journal-level comparison with the preprint summaries | 
| [`data_PLOS-OSI/`](data_PLOS-OSI/) | Downloaded dataset from PLOS OSI |
| [`outputs_graphs/`](outputs_graphs/) and [`outputs_tables/`](outputs_tables/) | Figures and tables saved during the exploration |

<br>


## Data Sources

- **Preprint summaries.** We used the funder- and journal-level CSVs shared by Lawrimore et al. The scripts read these files from the `develop` branch of the [authors’ repository](https://github.com/nimh-dsst/osm-preprint-2026/tree/develop/results)
- **PLOS Open Science Indicators (OSI), version 11.** We used both the PLOS and comparator datasets in our exploration. Copies of both CSVs are in [`data_PLOS-OSI/`](data_PLOS-OSI/). The original PLOS  OSI ver 11 dataset and documentation can be found on [the PLOS Figshare](https://doi.org/10.6084/M9.FIGSHARE.21687686.V11)


<br>