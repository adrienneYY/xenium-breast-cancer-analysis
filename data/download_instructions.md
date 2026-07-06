# Downloading the Raw Data

This analysis uses the **10x Genomics Xenium Prime 5K Human Breast Cancer
(FFPE)** dataset. Raw output is not tracked in this repository (too large
for git)- download it directly from 10x Genomics:

1. Go to the [10x Genomics Xenium datasets page](https://www.10xgenomics.com/datasets)
   and find the Xenium Prime 5K Human Breast Cancer FFPE dataset.
2. Download the "Xenium Output Bundle" for that sample and unzip it. You
   should end up with a directory named something like
   `Xenium_Prime_Breast_Cancer_FFPE_outs/` containing `cell_feature_matrix/`,
   `morphology_focus/`, `transcripts.parquet`, etc.

See the main [README](../README.md#how-to-reproduce) for the full
reproduction steps once the data is in place.