# Xenium Breast Cancer Spatial Transcriptomics: QC Threshold Comparison

Analysis of the 10x Genomics Xenium Prime 5K Breast Cancer (FFPE) dataset,
exploring how QC filtering choices affect cell clustering and cell type
composition in spatial transcriptomics data.

## Overview

Xenium is an imaging based spatial transcriptomics platform. It directly detects and
counts individual RNA transcripts in situ (on intact tissue sections), and
assigns each transcript to a cell based on its spatial coordinates. This
preserves the tissue architecture (which is lost when tissue is dissociated for single cell RNA-seq), 
but the tradeoff is the number of genes that can be reliably measured. 
This dataset measures a targeted panel (5,101 genes),
versus the whole transcriptome in scRNA-seq, and it's captured at much lower depth,
so per-cell counts are extremely sparse (median ~49 transcripts and ~46
genes/cell in this dataset).

This sparsity makes it important to tune cell-level QC filters with the broader biological question in mind. 
With overly lenient filters, low quality or empty "cells" (segmentation artifacts, background
signal) can dilute or fabricate clusters. Overly strict filters lead to rare cell populations being discarded as noise. This project addresses: **how much does QC filtering stringency actually change the clusters
and cell type composition recovered from a Xenium 5K breast cancer
dataset?** The question is motivated by recent work (*Nature Methods*, 2026)
on the SPLIT method, which highlights transcript diffusion and signal
contamination as a challenge for the expanded 5K gene panel.

## Dataset

- **Source:** [10x Genomics Xenium datasets](https://www.10xgenomics.com/datasets)
- **Total cells (unfiltered):** 699,110
- **Gene panel:** 5,101 genes
- **Median transcripts/cell:** 49
- **Median genes detected/cell:** 46

## Key Findings

| QC Threshold | Filter | Cells Retained | % of Lenient | Clusters Recovered |
|---|---|---|---|---|
| **Lenient** | nCount > 10, nFeature > 10 | 490,610 | 100% | 13 |
| **Standard** | nCount > 25, nFeature > 20 | 454,652 | 92.7% | 11 |
| **Strict** | nCount > 100, nFeature > 50 | 184,408 | 37.6% | 14 |

*(from `figures/03_qc_comparison_summary.csv`, the output of
`03_qc_comparison.Rmd`.)*

- **Lenient vs standard filtering** removed only ~7% of cells but
  collapsed two clusters, possibly because those populations are
  low quality/noise rather than distinct cell types
- **Strict filtering** retained just 37.6% of cells (relative to lenient),
  but recovered an *additional* cluster (14 vs. 13). Stringent filtering can 
  unmask rare populations previously diluted by noisy cells, but cost overall cell yield.
- **Recommendation:** Standard filtering (nCount > 25, nFeature > 20) offers
  the best balance of cell yield and cluster resolution for this dataset;
  strict filtering is worth performing as an add-on analysis if 
  specific rare populations are of particular interest.
- Cluster identities were not formally annotated in this analysis.
  Cell type assignment is a planned extended analysis.

## Repository Structure

```
xenium_breast_cancer_analysis/
├── README.md                        current file
├── renv.lock                        pinned package versions (renv::restore())
├── data/
│   ├── download_instructions.md     how to get the raw data
│   └── .gitkeep                      (raw data and .rds files not tracked)
├── notebooks/
│   ├── 01_load_and_qc.Rmd            Load data and baseline QC exploration
│   ├── 02_clustering.Rmd             Standard pipeline, unfiltered baseline
│   ├── 03_qc_comparison.Rmd          Three QC threshold comparison
│   └── 04_spatial_visualization.Rmd  Marker genes and spatial figures
├── figures/                          
│   ├── xenium_qc_summary_slides.pdf  4 slide visual summary
│   └── ...                            all output plots and tables
├── environment/
│   ├── package_install.R             package installation script  
└── docs/
    └── methods.md                    detailed methods
```

## How to Reproduce

1. Clone this repository
2. Download the raw Xenium data (see
   [`data/download_instructions.md`](data/download_instructions.md)) and
   note the path to the `Xenium_Prime_Breast_Cancer_FFPE_outs` directory.
3. Open `xenium_breast_cancer_analysis.Rproj` in RStudio, then install the
   exact package versions this analysis was run with:
   ```r
   renv::restore()
   ```
4. Point the notebooks at your local copy of the raw data
5. Run the notebooks in order. Each is self-contained except where noted:
   - **`01_load_and_qc.Rmd`** - loads raw data, outputs baseline QC violin
     plot + summary stats. No dependency on other notebooks
   - **`02_clustering.Rmd`** - loads raw data, runs the full project pipeline on the unfiltered object, saves
     `data/xenium_standard.rds`
   - **`03_qc_comparison.Rmd`** - loads raw data, applies all three QC
     thresholds, runs the pipeline three times, saves
     `data/xenium_{lenient,standard,strict}.rds` and the comparison
     figures/summary table
   - **`04_spatial_visualization.Rmd`** - requires `03_qc_comparison.Rmd`
     to have been run first (reads saved `.rds` outputs); produces the
     marker gene and spatial figures

## Methods Summary

**Data** The 10x Genomics Xenium Prime 5K Breast Cancer (FFPE) dataset: a
formalin-fixed, paraffin-embedded human breast cancer tissue section
profiled with the Xenium Prime 5K panel (5,101 genes) with 699,110 cells before any QC filtering.

**QC approach** Three filtering strategies (lenient, standard, strict -
see table above) are each run through an identical clustering pipeline,
isolating the effect of the QC threshold from any other analysis choice.
Because the full dataset (~700k cells) exceeds available RAM, 50,000 cells were 
randomly subsampled (set.seed(42)) from each 
filtered object. The standard pipeline (normalize -> variable features -> scale 
-> PCA -> neighbors -> graph-based clustering at resolution 0.3 -> UMAP) was run 
on the subsample, and cluster labels were projected back to all cells using 
`ProjectData()`. Note: leverage score sketching via `SketchData()` was 
attempted but requires >32GB RAM for this dataset size; random subsampling 
was used as an alternative.

**Tools** Seurat 5 (`LoadXenium()`, `ImageDimPlot()`) for the core pipeline and spatial visualization;
`ggplot2`/`patchwork` for figure composition; `renv` for environment
reproducibility. Pipeline structure follows 10x Genomics Xenium 5K
analysis tutorial (linked below).

## Citation / Data Source

- Raw data: [10x Genomics Xenium Prime 5K Breast Cancer FFPE dataset](https://www.10xgenomics.com/datasets).
- Pipeline adapted from the [10x Genomics Xenium 5K data analysis tutorial](https://github.com/10XGenomics/analysis_guides/blob/main/Xenium_5k_data_analysis_journey.ipynb).
- QC comparison framing inspired by the SPLIT method (*Nature Methods*,
  2026) on transcript diffusion in Xenium 5K data. 
    Bilous M, Buszta D, Bac J, Kang S, Dong Y, Tissot S, Andre S, Alexandre Gaveta M, Voize C, Peters S, Homicsko K, Gottardo R. Resolving sensitivity, specificity and signal contamination in Xenium spatial transcriptomics. Nat Methods. 2026 Jun;23(6):1152-1162. doi: 10.1038/s41592-026-03089-8. Epub 2026 Apr 30. PMID: 42062553; PMCID: PMC13259927.

## Acknowledgements
Code documentation and repository structure were refined with assistance 
from Claude (Anthropic). All analysis design, biological interpretation, 
and results are the author's own.