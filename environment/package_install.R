# ── CRAN packages ──────────────────────────────────────────
install.packages(c(
  "Seurat",
  "ggplot2",
  "patchwork",
  "here",
  "arrow",        # required for LoadXenium() parquet files
  "dplyr",
  "reticulate",
  "devtools",
  "rmarkdown"
))

# hdf5r excluded: incompatible with HDF5 v2.1.1 on Apple Silicon (macOS 26+)
# Not required — LoadXenium() reads transcripts.parquet via arrow instead

# ── Bioconductor packages ──────────────────────────────────
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install(c(
  "glmGamPoi",
  "zellkonverter",
  "viridis"
))

# ── GitHub packages ────────────────────────────────────────
# BPCells: on-disk matrix format, important for large Xenium datasets
if (!requireNamespace("BPCells", quietly = TRUE))
  remotes::install_github("bnprks/BPCells/r")

# SeuratData: tutorial datasets
devtools::install_github("satijalab/seurat-data")