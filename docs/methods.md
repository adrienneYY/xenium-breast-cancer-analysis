# Methods

Detailed methods write-up for the QC threshold comparison. For a shorter version see the main [README](../README.md#methods-summary).

## 1. Data

10x Genomics Xenium Prime 5K Human Breast Cancer (FFPE), one tissue section.
Xenium Prime 5K panel (5,101 genes). Raw output loaded with
`LoadXenium(data_dir, fov = "fov")` (Seurat 5). 699,110 cells called before
any QC filtering; median 49 transcripts and 46 genes detected per cell
(see `notebooks/01_load_and_qc.Rmd`).

## 2. QC filtering strategies

Three thresholds on `nCount_Xenium` (transcripts/cell) and `nFeature_Xenium`
(genes/cell), applied to the same raw object:

| Condition | nCount | nFeature | Rationale |
|---|---|---|---|
| Lenient  | > 10  | > 10 | Removes only near empty cells (likely background/segmentation noise) |
| Standard | > 25  | > 20 | Just below the panel wide median; drops the sparsest tail, keeps typical cells |
| Strict   | > 100 | > 50 | Retains only cells well above median, keeping high-confidence cells|

See `notebooks/03_qc_comparison.Rmd` for the `subset()` calls.

## 3. Clustering pipeline

Applied identically to the unfiltered baseline (`02_clustering.Rmd`) and to
each of the three filtered objects (`03_qc_comparison.Rmd`), so cluster
counts and spatial patterns are comparable across conditions:

1. **Subsampling** - 50,000 cells were randomly sampled from each filtered
   object (`sample(Cells(), size = 50000), set.seed(42)`). `SketchData()` 
   with `LeverageScore` was attempted but exceeds 32GB RAM on this 699k-cell dataset. Random 
   subsampling was used as an alternative. Results are 
   equivalent for identifying major cell lineages; leverage scoring would 
   better preserve rare populations but requires >32GB RAM.
2. **Normalize / feature selection** - `NormalizeData()`,
   `FindVariableFeatures()` (defaults) on the subsampled cells.
3. **Scale** — `ScaleData()` on variable features only, on the 50k 
   subsampled cells.
4. **PCA** - `RunPCA(npcs = 50)`; `dims = 1:25` used downstream based on
   the elbow-plot inflection point (`figures/02_elbow_plot.png`).
5. **Clustering** - `FindNeighbors(dims = 1:25)` +
   `FindClusters(resolution = 0.3)`. Resolution 0.3 is coarse,
   targeting major lineages (epithelial/tumor, immune, stromal,
   endothelial) rather than finer subtypes, so cluster counts are
   robust enough to compare across QC conditions.
6. **UMAP** - `RunUMAP(dims = 1:25, return.model = TRUE)` (model retained
   for projection in the next step).
7. **Project to all cells** — `ProjectData()` transfers `seurat_clusters`
   labels from the 50k subsample to all cells in the filtered object as
   `cluster_full`, using the retained PCA/UMAP models.

## 4. Cross-condition comparison

Cluster IDs are **not** biologically matched across lenient/standard/strict. 
The same integer label can refer to different cell populations in each
condition, since each condition is clustered independently. Colors are
assigned from the union of cluster IDs across all three conditions so the
same ID always renders in the same color for visual comparison, but IDs are
not intended to be read as a cross-condition mapping. See
`notebooks/03_qc_comparison.Rmd` section 4 for the shared palette
construction.

## 5. Spatial visualization

`04_spatial_visualization.Rmd` works from the standard filtered object
(the recommended threshold). Canonical breast cancer lineage markers
(`EPCAM`, `CD3E`, `MS4A1`, `CD68`, `PECAM1`, `ACTA2`) are plotted spatially
and on UMAP as an independent sanity check. Spatially coherent clusters
that also express the expected lineage marker are stronger evidence of a
real, distinct cell type than either signal alone.

---

