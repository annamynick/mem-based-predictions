# rp_plot_supplemental


# Change current working directory 
setwd("~/Dropbox_Lab/projects/pattern-completion/analysis-scripts-CB-s2/memory-based-predictions/analysis-scripts/")

# Get bar_with_lines code 
file_path <- "~/Dropbox_Lab/tools/annatools/R/bar_with_lines.R"
source("~/Dropbox_Lab/tools/annatools/R/bar_with_jitter.R")

# familiarity: 
bar_with_jitter(
  csv_path = "../data-mats/familiarity_pct_E1+E3+E6.csv",
  csv_dataname = "",
  bar_labels = c("Expt 1", "Expt 3", "Expt 4"),
  bar_colors = c("Expt 1" = "grey40", "Expt 3" = "grey40", "Expt 4" = "grey40"),
  ylabel = "% Real-life familiarity",
  y_min = 0,
  y_max = 110,
  do_signif = FALSE,
  plot_width_mm = 54,
  plot_height_mm = 54,
  bar_width_mm = 15,
  y_by = 25,
  plot_filename = "supp_familiarity_pct"
)

# explicit accuracy 
explicit_acc = read.csv("../data-mats/explicit_acc_pct_E16.csv", header = FALSE);
t.test(explicit_acc$V1, mu = 33.33, alternative = "two.sided") # Experiment 1 ttest
t.test(explicit_acc$V2, mu = 33.33, alternative = "two.sided") # Experiment 4 ttest


bar_with_jitter(
  csv_path = "../data-mats/explicit_acc_pct_E16.csv",
  csv_dataname = "",
  bar_labels = c("Expt 1", "Expt 4"),
  bar_colors = c("Expt 1" = "grey40", "Expt 4" = "grey40"),
  ylabel = "Accuracy (% correct)",
  y_min = 0,
  y_max = 110,
  do_signif = FALSE,
  plot_width_mm = 54,
  plot_height_mm = 54,
  bar_width_mm = 15,
  y_by = 25,
  dashed_line = 33.33,
  plot_filename = "supp_explicit_acc"
)

# Open/Closed accuracy
bar_with_jitter(
  csv_path = "../data-mats/oc_acc_E1236.csv",
  csv_dataname = "",
  bar_labels = c("Expt 1", "Expt 2", "Expt 3", "Expt 4"),
  bar_colors = c("Expt 1" = "grey40", "Expt 2" = "grey40","Expt 3" = "grey40", "Expt 4" = "grey40"),
  ylabel = "Accuracy (% correct)",
  y_min = 0,
  y_max = 110,
  do_signif = FALSE,
  plot_width_mm = 54,
  plot_height_mm = 54,
  bar_width_mm = 15,
  y_by = 25,
  dashed_line = 50,
  plot_filename = "supp_oc_acc",
  x_expansion = .25
)


