# ==============================================================================
# BOX PLOT WITH ANOVA & TUKEY FOR 4 DPI ONLY (VISIBLE IN RSTUDIO PLOTS)
# ==============================================================================

if (!requireNamespace("multcompView", quietly = TRUE)) install.packages("multcompView", type = "binary")
library(ggplot2); library(dplyr); library(readxl); library(multcompView)

cat("PLEASE SELECT YOUR EXCEL FILE (.xlsx)...\n")
original_path <- file.choose()
temp_file_path <- file.path(tempdir(), "temp_data.xlsx")
file.copy(original_path, temp_file_path, overwrite = TRUE)
all_experiments_raw <- read_excel(temp_file_path, sheet = 1)
unlink(temp_file_path)

# Φιλτράρισμα ΑΠΟΚΛΕΙΣΤΙΚΑ για 4 DPI
data_4dpi <- all_experiments_raw %>%
  rename(bacterium_id = 1, replicate_id = 2, assay = 3, time_point = 4, radial_growth = 5) %>%
  mutate(bacterium_id = trimws(as.character(bacterium_id)), radial_growth = as.numeric(radial_growth),
         time_point = as.numeric(time_point), assay = as.factor(assay)) %>%
  filter(time_point == 4) %>% na.omit()

if("control" %in% unique(data_4dpi$bacterium_id)){
  data_4dpi$bacterium_id <- factor(data_4dpi$bacterium_id)
  data_4dpi$bacterium_id <- relevel(data_4dpi$bacterium_id, ref = "control")
}

# Στατιστική Ανάλυση Tukey για 4 DPI
all_letters_4 <- data.frame()
for (ass in unique(data_4dpi$assay)) {
  sub_data <- data_4dpi %>% filter(assay == ass)
  if (nrow(sub_data) > length(unique(sub_data$bacterium_id))) {
    model <- aov(radial_growth ~ bacterium_id, data = sub_data)
    tukey_letters <- multcompLetters4(model, TukeyHSD(model))
    labels_df <- sub_data %>% group_by(bacterium_id) %>%
      summarise(max_growth = max(radial_growth, na.rm = TRUE), .groups = 'drop') %>%
      mutate(assay = ass, stat_letter = tukey_letters$bacterium_id$Letters[as.character(bacterium_id)])
    all_letters_4 <- rbind(all_letters_4, labels_df)
  }
}
all_letters_4$y_pos <- all_letters_4$max_growth + (max(data_4dpi$radial_growth) * 0.04)

# Δημιουργία και εμφάνιση του Box Plot για το 4 DPI στο RStudio
plot_4dpi <- ggplot(data_4dpi, aes(x = assay, y = radial_growth, fill = bacterium_id)) +
  geom_boxplot(outlier.size = 1.5, alpha = 0.8, position = position_dodge(0.8)) +
  geom_text(data = all_letters_4, aes(x = assay, y = y_pos, label = stat_letter, group = bacterium_id),
            position = position_dodge(0.8), vjust = 0, fontface = "bold", size = 3.8) +
  labs(title = "Botrytis Radial Growth - Day 4 DPI", x = "Assay", y = "Radial Growth", fill = "Sample / Control") +
  theme_minimal(base_size = 14) + theme(plot.title = element_text(face = "bold", hjust = 0.5))

print(plot_4dpi) # Εμφανίζεται κατευθείαν στα Plots δεξιά