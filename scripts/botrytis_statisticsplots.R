
# ============================================================
# BOTRYTIS RADIAL GROWTH - DAY 5 AND DAY 7 DPI
# ============================================================

library(ggplot2)
library(dplyr)
library(readxl)
library(multcompView)


# ============================================================
# 1. SELECT EXCEL FILE
# ============================================================

cat("PLEASE SELECT YOUR EXCEL FILE (.xlsx)...\n")

original_path <- file.choose()

all_experiments_raw <- read_excel(
  original_path,
  sheet = 1
)


# ============================================================
# 2. RENAME THE 5 COLUMNS
# ============================================================

data <- all_experiments_raw %>%
  rename(
    bacterium_id = 1,
    replicate_id = 2,
    assay = 3,
    time_point = 4,
    radial_growth = 5
  ) %>%
  mutate(
    bacterium_id = trimws(as.character(bacterium_id)),
    replicate_id = as.character(replicate_id),
    assay = as.factor(assay),
    time_point = as.numeric(time_point),
    radial_growth = as.numeric(radial_growth)
  )


# ============================================================
# 3. FUNCTION FOR TUKEY ANALYSIS
# ============================================================

run_tukey <- function(data_dpi, day) {

  all_letters <- data.frame()
  all_comparisons <- data.frame()

  for (ass in unique(data_dpi$assay)) {

    sub_data <- data_dpi %>%
      filter(assay == ass) %>%
      droplevels()

    if (
      nrow(sub_data) > length(unique(sub_data$bacterium_id)) &&
      length(unique(sub_data$bacterium_id)) > 1
    ) {

      model <- aov(
        radial_growth ~ bacterium_id,
        data = sub_data
      )

      tukey_result <- TukeyHSD(model)

      # Tukey pairwise comparisons
      tukey_df <- as.data.frame(
        tukey_result[["bacterium_id"]]
      )

      tukey_df$Comparison <- rownames(tukey_df)
      tukey_df$Assay <- as.character(ass)
      tukey_df$DPI <- day

      all_comparisons <- bind_rows(
        all_comparisons,
        tukey_df
      )

      # Tukey grouping letters
      tukey_letters <- multcompLetters4(
        model,
        tukey_result
      )

      letters_df <- sub_data %>%
        group_by(bacterium_id) %>%
        summarise(
          max_growth = max(
            radial_growth,
            na.rm = TRUE
          ),
          .groups = "drop"
        ) %>%
        mutate(
          assay = as.character(ass),
          stat_letter = tukey_letters[["bacterium_id"]][["Letters"]][
            as.character(bacterium_id)
          ],
          DPI = day
        )

      all_letters <- bind_rows(
        all_letters,
        letters_df
      )
    }
  }

  list(
    letters = all_letters,
    comparisons = all_comparisons
  )
}


# ============================================================
# 4. FUNCTION TO CREATE PLOT
# ============================================================

create_plot <- function(data_dpi, day, filename) {

  plot_dpi <- ggplot(
    data_dpi,
    aes(
      x = assay,
      y = radial_growth,
      fill = bacterium_id
    )
  ) +

    # BOXPLOTS
    geom_boxplot(
      outlier.size = 1.5,
      alpha = 0.8,
      width = 0.65,
      position = position_dodge(
        width = 0.8
      )
    ) +

    # Y AXIS
    coord_cartesian(
      ylim = c(5.5, 8.9)
    ) +

    # LABELS
    labs(
      title = paste0(
        "Botrytis Radial Growth - Day ",
        day,
        " DPI"
      ),
      x = "Assay",
      y = "Radial Growth",
      fill = "Sample / Control"
    ) +

    # THEME
    theme_minimal(
      base_size = 14
    ) +

    theme(

      plot.title = element_text(
        face = "bold",
        hjust = 0.5,
        size = 17
      ),

      axis.title.x = element_text(
        size = 14,
        face = "bold"
      ),

      axis.title.y = element_text(
        size = 14,
        face = "bold"
      ),

      axis.text.x = element_text(
        size = 13,
        face = "bold"
      ),

      axis.text.y = element_text(
        size = 12
      ),

      legend.title = element_text(
        face = "bold"
      ),

      legend.text = element_text(
        size = 11
      ),

      panel.grid.major.x =
        element_blank(),

      plot.margin = margin(
        15, 15, 15, 15
      )
    )

  print(plot_dpi)

  ggsave(
    filename = filename,
    plot = plot_dpi,
    width = 10,
    height = 7,
    dpi = 300
  )

  cat(
    "\nPlot saved as:",
    filename,
    "\n"
  )

  return(plot_dpi)
}


# ============================================================
# 5. ANALYSIS FOR 5 DPI
# ============================================================

data_5dpi <- data %>%
  filter(time_point == 5) %>%
  na.omit()

cat(
  "\nNumber of observations at 5 DPI:",
  nrow(data_5dpi),
  "\n"
)

cat("\nSamples included at 5 DPI:\n")
print(unique(data_5dpi$bacterium_id))

cat("\nAssays included at 5 DPI:\n")
print(unique(data_5dpi$assay))

tukey_5 <- run_tukey(
  data_5dpi,
  5
)

plot_5dpi <- create_plot(
  data_5dpi,
  5,
  "Botrytis_Radial_Growth_5DPI.png"
)


# ============================================================
# 6. ANALYSIS FOR 7 DPI
# ============================================================

data_7dpi <- data %>%
  filter(time_point == 7) %>%
  na.omit()

cat(
  "\nNumber of observations at 7 DPI:",
  nrow(data_7dpi),
  "\n"
)

cat("\nSamples included at 7 DPI:\n")
print(unique(data_7dpi$bacterium_id))

cat("\nAssays included at 7 DPI:\n")
print(unique(data_7dpi$assay))

tukey_7 <- run_tukey(
  data_7dpi,
  7
)

plot_7dpi <- create_plot(
  data_7dpi,
  7,
  "Botrytis_Radial_Growth_7DPI.png"
)


# ============================================================
# 7. SAVE TUKEY PAIRWISE COMPARISONS
# ============================================================

all_tukey_results <- bind_rows(
  tukey_5$comparisons,
  tukey_7$comparisons
)

write.csv(
  all_tukey_results,
  "Botrytis_Tukey_Results_5_and_7DPI.csv",
  row.names = FALSE
)


# ============================================================
# 8. SAVE TUKEY GROUPING LETTERS SEPARATELY
# ============================================================

all_tukey_letters <- bind_rows(
  tukey_5$letters,
  tukey_7$letters
)

write.csv(
  all_tukey_letters,
  "Botrytis_Tukey_Letters_5_and_7DPI.csv",
  row.names = FALSE
)


# ============================================================
# 9. FINISHED
# ============================================================

cat("\nAll analyses completed successfully.\n")
cat("Created plots for 5 DPI and 7 DPI.\n")
cat("Tukey pairwise results saved to CSV.\n")
cat("Tukey grouping letters saved to CSV.\n")
