# plot_rp_nofamiliarity.R

# Change current working directory 
setwd("~/Dropbox_Lab/projects/pattern-completion/analysis-scripts-CB-s2/memory-based-predictions/analysis-scripts/")

# Get bar_with_lines code 
source("~/Dropbox_Lab/tools/annatools/R/bar_with_lines.R")

# load in data 

M = read.csv('rp_nofamiliarity_w_exclus.csv')

bar_with_lines(
  csv_path = "./rp_nofamiliarity_w_exclus.csv",
  csv_dataname = "",
  bar_labels = c("Same-scene", "Neutral"),
  bar_colors = c("Same-scene" = "#136289", "Neutral" = "#5d88a4"),
  y_min = 0.7,
  y_max = 1.7,
  do_signif = TRUE,
  plot_width_mm = 54,
  plot_height_mm = 54,
  bar_width = 10,
  x_expansion = 1.3,
  significance_level = "**"
  )


