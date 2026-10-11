# ============================================================
# INHIBITION ASSAY
# XCC + CMM
# 1_ASSAY + 2_ASSAY
# WITHOUT CONTROL IN GRAPH
# INHIBITION IN cm
# ============================================================

library(readxl)
library(dplyr)
library(ggplot2)


# ============================================================
# 1. SELECT EXCEL FILE
# ============================================================

file_path <- file.choose()

raw_data <- read_excel(
  file_path,
  sheet = " 1_ASSAY",
  col_names = FALSE
)


# ============================================================
# 2. SAMPLES
# ============================================================

samples <- c(
  "SRL1098",
  "SRL1112",
  "SRL1123",
  "SRL1260",
  "SRL1263",
  "SRL1264",
  "SRL1433"
)


# ============================================================
# 3. DATA BLOCKS
# ============================================================

start_rows <- c(
  3,   # SRL1098
  8,   # SRL1112
  13,  # SRL1123
  18,  # SRL1260
  23,  # SRL1263
  28,  # SRL1264
  33   # SRL1433
)


# ============================================================
# 4. CALCULATION FUNCTION
# ============================================================

calculate_inhibition <- function(
    data,
    sample,
    start_row,
    assay,
    pathogen
) {

  sub <- data[
    start_row:(start_row + 3),
    ,
    drop = FALSE
  ]


  # ----------------------------------------------------------
  # Correct columns
  # ----------------------------------------------------------

  if (
    assay == "1_ASSAY" &&
    pathogen == "XCC"
  ) {

    label_col <- 5
    length_col <- 7

  } else if (
    assay == "1_ASSAY" &&
    pathogen == "CMM"
  ) {

    label_col <- 9
    length_col <- 11

  } else if (
    assay == "2_ASSAY" &&
    pathogen == "XCC"
  ) {

    label_col <- 13
    length_col <- 15

  } else if (
    assay == "2_ASSAY" &&
    pathogen == "CMM"
  ) {

    label_col <- 17
    length_col <- 19

  }


  # ----------------------------------------------------------
  # Labels
  # ----------------------------------------------------------

  labels <- toupper(
    trimws(
      as.character(
        sub[[label_col]]
      )
    )
  )


  # ----------------------------------------------------------
  # Mean inhibition halo
  # ----------------------------------------------------------

  halo_values <- as.numeric(
    unlist(
      sub[
        labels == "INHIBITION",
        length_col
      ]
    )
  )

  mean_halo <- mean(
    halo_values,
    na.rm = TRUE
  )


  # ----------------------------------------------------------
  # Mean dot
  # ----------------------------------------------------------

  dot_values <- as.numeric(
    unlist(
      sub[
        labels == "DOT",
        length_col
      ]
    )
  )

  mean_dot <- mean(
    dot_values,
    na.rm = TRUE
  )


  # ----------------------------------------------------------
  # Calculate inhibition in cm
  # ----------------------------------------------------------

  if (
    sample == "Control"
  ) {

    inhibition_cm <- 0

  } else {

    inhibition_cm <- mean_halo - mean_dot

  }


  # ----------------------------------------------------------
  # Return
  # ----------------------------------------------------------

  data.frame(
    Sample = sample,
    Assay = assay,
    Pathogen = pathogen,
    Mean_Halo = mean_halo,
    Mean_Dot = mean_dot,
    Inhibition_cm = inhibition_cm
  )
}


# ============================================================
# 5. CALCULATE ALL RESULTS
# ============================================================

results <- data.frame()


for (i in seq_along(samples)) {

  sample <- samples[i]
  start_row <- start_rows[i]


  # 1_ASSAY - XCC

  results <- rbind(
    results,
    calculate_inhibition(
      raw_data,
      sample,
      start_row,
      "1_ASSAY",
      "XCC"
    )
  )


  # 1_ASSAY - CMM

  results <- rbind(
    results,
    calculate_inhibition(
      raw_data,
      sample,
      start_row,
      "1_ASSAY",
      "CMM"
    )
  )


  # 2_ASSAY - XCC

  results <- rbind(
    results,
    calculate_inhibition(
      raw_data,
      sample,
      start_row,
      "2_ASSAY",
      "XCC"
    )
  )


  # 2_ASSAY - CMM

  results <- rbind(
    results,
    calculate_inhibition(
      raw_data,
      sample,
      start_row,
      "2_ASSAY",
      "CMM"
    )
  )

}


# ============================================================
# 6. ROUND VALUES
# ============================================================

results <- results %>%
  mutate(
    Mean_Halo = round(Mean_Halo, 2),
    Mean_Dot = round(Mean_Dot, 2),
    Inhibition_cm = round(Inhibition_cm, 2)
  )


# ============================================================
# 7. PRINT RESULTS
# ============================================================

cat("\n")
cat("============================================\n")
cat("INHIBITION RESULTS (cm)\n")
cat("============================================\n\n")

print(results)


# ============================================================
# 8. SAVE RESULTS
# ============================================================

write.csv(
  results,
  "Inhibition_cm_Results.csv",
  row.names = FALSE
)


# ============================================================
# 9. ORDER FACTORS
# ============================================================

results$Sample <- factor(
  results$Sample,
  levels = samples
)

results$Assay <- factor(
  results$Assay,
  levels = c(
    "1_ASSAY",
    "2_ASSAY"
  )
)

results$Pathogen <- factor(
  results$Pathogen,
  levels = c(
    "XCC",
    "CMM"
  )
)


# ============================================================
# 10. CREATE GRAPH
# ============================================================

plot_inhibition <- ggplot(
  results,
  aes(
    x = Sample,
    y = Inhibition_cm,
    fill = Assay
  )
) +

  # ----------------------------------------------------------
  # Bars
  # ----------------------------------------------------------

  geom_col(
    position = position_dodge(
      width = 0.8
    ),
    width = 0.7,
    color = "black",
    linewidth = 0.3
  ) +

  # ----------------------------------------------------------
  # cm labels - 2 decimal places
  # ----------------------------------------------------------

  geom_text(
    aes(
      label = sprintf(
        "%.2f",
        Inhibition_cm
      )
    ),
    position = position_dodge(
      width = 0.8
    ),
    vjust = -0.4,
    fontface = "bold",
    size = 3.5
  ) +

  # ----------------------------------------------------------
  # Separate XCC / CMM
  # ----------------------------------------------------------

  facet_wrap(
    ~ Pathogen,
    ncol = 1
  ) +

  # ----------------------------------------------------------
  # Labels
  # ----------------------------------------------------------

  labs(
    title =
      "Inhibition of Bacterial Isolates Against Plant Pathogens",

    subtitle =
      "Inhibition = mean inhibition halo − mean dot",

    x =
      "Bacterial Strain",

    y =
      "Inhibition halo (cm)",

    fill =
      "Assay"
  ) +

  # ----------------------------------------------------------
  # Y axis
  # ----------------------------------------------------------

  coord_cartesian(
    ylim = c(
      0,
      max(
        results$Inhibition_cm,
        na.rm = TRUE
      ) + 1
    )
  ) +

  # ----------------------------------------------------------
  # Theme
  # ----------------------------------------------------------

  theme_minimal(
    base_size = 14
  ) +

  theme(

    plot.title =
      element_text(
        face = "bold",
        hjust = 0.5,
        size = 17
      ),

    plot.subtitle =
      element_text(
        hjust = 0.5,
        size = 11
      ),

    axis.title.x =
      element_text(
        face = "bold",
        size = 14
      ),

    axis.title.y =
      element_text(
        face = "bold",
        size = 14
      ),

    axis.text.x =
      element_text(
        face = "bold",
        size = 11,
        angle = 90,
        vjust = 0.5,
        hjust = 1
      ),

    axis.text.y =
      element_text(
        size = 11
      ),

    strip.text =
      element_text(
        face = "bold",
        size = 14
      ),

    legend.title =
      element_text(
        face = "bold"
      ),

    panel.grid.major.x =
      element_blank()

  )


# ============================================================
# 11. DISPLAY GRAPH
# ============================================================

print(plot_inhibition)


# ============================================================
# 12. SAVE GRAPH
# ============================================================

ggsave(
  filename =
    "Bacterial_Inhibition_XCC_CMM_cm.png",

  plot =
    plot_inhibition,

  width =
    11,

  height =
    9,

  dpi =
    300
)


# ============================================================
# FINISHED
# ============================================================

cat("\n")
cat("============================================\n")
cat("ANALYSIS COMPLETED SUCCESSFULLY\n")
cat("============================================\n")

cat("\n")
cat("7 bacterial strains included.\n")
cat("Control excluded from graph.\n")
cat("2 assays × 2 pathogens.\n")
cat("Inhibition expressed in cm.\n")
cat("\n")

cat("Created files:\n")
cat("1. Inhibition_cm_Results.csv\n")
cat("2. Bacterial_Inhibition_XCC_CMM_cm.png\n")