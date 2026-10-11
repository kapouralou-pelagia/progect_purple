# 1. Load required libraries
library(ggplot2)
library(dplyr)

# 2. Input data parsed directly from your antiSMASH HTML files
antismash_data <- data.frame(
  Strain = c(
    rep("1098", 9), rep("1112", 16), rep("1123", 9), 
    rep("1260", 10), rep("1263", 22), rep("1264", 10), rep("1433", 8)
  ),
  BGC_Type = c(
    # 1098
    "RiPP-like", "arylpolyene", "RiPP-like", "acyl_amino_acids", "thioamide-NRP", "terpene", "NAPAA", "RiPP-like", "terpene-precursor",
    # 1112
    "terpene-precursor", "RiPP-like", "NAPAA", "terpene", "thioamide-NRP", "RiPP-like", "azole-containing-RiPP", "NRPS", "terpene-precursor", "RiPP-like", "NAPAA", "terpene", "thioamide-NRP", "RiPP-like", "azole-containing-RiPP", "NRPS",
    # 1123
    "RiPP-like", "arylpolyene", "RiPP-like", "terpene-precursor", "RiPP-like", "NAPAA", "terpene", "thioamide-NRP", "acyl_amino_acids",
    # 1260
    "NAPAA", "terpene", "thioamide-NRP", "RiPP-like", "indole", "RiPP-like", "arylpolyene", "RiPP-like", "terpene-precursor", "RiPP-like",
    # 1263
    "RiPP-like", "RiPP-like", "cyanobactin", "NRPS", "NRP-metallophore", "RiPP-like", "indole", "acyl_amino_acids", "terpene", "NAPAA", "terpene-precursor", "RiPP-like", "RiPP-like", "cyanobactin", "NRPS", "NRP-metallophore", "RiPP-like", "indole", "acyl_amino_acids", "terpene", "NAPAA", "terpene-precursor",
    # 1264
    "RiPP-like", "tropodithietic-acid", "RiPP-like", "indole", "RiPP-like", "acyl_amino_acids", "terpene", "NAPAA", "RiPP-like", "terpene-precursor",
    # 1433
    "terpene-precursor", "RiPP-like", "NAPAA", "terpene", "thioamide-NRP", "RiPP-like", "azole-containing-RiPP", "NRPS"
  )
)

# 3. Summarize counts per Strain and BGC Type
bgc_summary <- antismash_data %>%
  group_by(Strain, BGC_Type) %>%
  summarise(Count = n(), .groups = 'drop')

# 4. Create the Stacked Bar Plot
ggplot(bgc_summary, aes(x = Strain, y = Count, fill = BGC_Type)) +
  geom_col(width = 0.6, color = "black", size = 0.2) + # Distinct borders on bars
  scale_fill_brewer(palette = "Set3") +               # Beautiful scientific palette
  labs(
    title = "Distribution of Biosynthetic Gene Clusters (BGCs)",
    subtitle = "Analysis based on antiSMASH secondary metabolite prediction",
    x = "Bacterial Strain ID",
    y = "Number of Clusters",
    fill = "BGC Category / Type"
  ) +
  theme_bw(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 11, face = "italic", hjust = 0.5),
    # ΔΙΟΡΘΩΣΗ: Προστέθηκαν τα ορίσματα angle, hjust και vjust για κάθετη εμφάνιση
    axis.text.x = element_text(face = "bold", size = 12, angle = 90, hjust = 1, vjust = 0.5),
    axis.text.y = element_text(size = 12),
    panel.grid.major.x = element_blank(), # Cleans the graph from vertical lines
    legend.title = element_text(face = "bold")
  )

# 5. Automatically save the graph in high resolution
ggsave("antismash_bgc_distribution.png", width = 10, height = 7, dpi = 300)
