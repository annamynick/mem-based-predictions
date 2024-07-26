bar_with_jitter <- function(csv_path,
                           csv_dataname = "",
                           bar_labels,
                           bar_colors,
                           ylabel,
                           y_min,
                           y_max,
                           bar_width_mm = 10,
                           plot_width_mm = 54.67,
                           plot_height_mm = 54.67,
                           save_path = "~/Desktop/",
                           do_signif = TRUE,
                           x_expansion = .5,
                           y_by = 1,
                           dashed_line = 999,
                           plot_filename = "bar_plot") 
  {
  # Load libraries
  library(ggplot2)
  library(extrafont)
  library(tidyverse)
  library(ggsignif)

  bar_width_inches <- bar_width_mm / 25.4

  # Load data from .csv file
  plot_data <- read.csv(csv_path, header = FALSE)

  # Prepare data for plotting
  plot_data <- data.frame(plot_data)
  rownames(plot_data) <- 1:nrow(plot_data)
  colnames(plot_data) <- bar_labels # Assign column names
  plot_data$subj_num <- 1:nrow(plot_data) # subj num can also represent observation num; this just ties cols together
  
  # Convert to long format
  obs_df <- plot_data %>%
    pivot_longer(
      cols = -subj_num,
      names_to = "Condition",
      values_to = "Value"
    )

  print(obs_df, n = 1000)

  # Correct the order of the bars
  obs_df$Condition <- factor(obs_df$Condition, levels = bar_labels)
  
  # Print the range of the values
  print(paste("Min Value:", min(obs_df$Value)))
  print(paste("Max Value:", max(obs_df$Value)))
  
  # y_min = min(obs_df$Value)
  # y_max = max(obs_df$Value)

  # Calculate the mean of the medians (or whatever else) for the bars
  mean_df <- obs_df %>%
    group_by(Condition) %>%
    summarise(mean_value = mean(Value, na.rm = TRUE))

  p <- ggplot(mean_df, aes(Condition, mean_value)) +
    geom_bar(aes(fill = Condition), stat = "identity",
             width = bar_width_inches) + # Set bar width to 10mm. Can also add: color = "black", size=0.3 for lines around bars 
    geom_jitter(data = obs_df, aes(x = Condition, y = Value, group = Value),
                color = "#d3d3d3",
                size = 1.5,
                shape = 1,
                width = 0.15,
                height = 0) +
    scale_y_continuous(breaks = seq(y_min, y_max, y_by), expand = c(0, 0)) + 
    scale_x_discrete(expand = expansion(mult = c(x_expansion, x_expansion))) +
    coord_cartesian(ylim=c(y_min,y_max)) + 
    scale_fill_manual(values = bar_colors) + # Set custom hex colors for the bars
    labs(
      title = NULL,
      x = NULL,
      y = ylabel
    ) + # Remove y-axis label
    theme_minimal() +
    theme(
      panel.grid.major = element_blank(), # Remove major grid lines
      panel.grid.minor = element_blank(), # Remove minor grid lines
      panel.background = element_blank(), # Remove background
      axis.line = element_line(color = "black"), # Add axis lines
      axis.ticks.y = element_line(color = "black"), # Add y-axis tick marks
      text = element_text(family = "Arial", color = "black"), # Set font to 'sans' and color to black
      plot.title = element_text(size = 7, face = "bold", color = "black"),
      axis.title = element_text(size = 7, color = "black"),
      axis.text = element_text(size = 7, color = "black"), # Explicitly set axis text color to black
      legend.position = "none", # Hide legend
      plot.margin = unit(c(0, 0, 0, 0), "cm") # Remove all plot margins
    )

  # Add significance bars and stars
  if (do_signif == TRUE) {
    p <- p + geom_signif(
      comparisons = split(t(combn(levels(mean_df$Condition), 2)), seq(nrow(t(combn(levels(mean_df$Condition), 2))))),
      map_signif_level = TRUE,
      step_increase = .2,
      textsize = 3,
      size = .3,
      vjust = .3
    )
  }
  
  # Add a dashed line
  if (dashed_line != 999) {
    p <- p + geom_hline(yintercept = dashed_line, linetype = "dashed", linetype = "dashed", color = "black", size = .4)  # Add a horizontal dashed line at y = y_value
  }
   

  # Print plot to plots tab
  print(p)

  # Save plot to file
  plot_file_path <- file.path(save_path, paste0(plot_filename, ".pdf"))
  ggsave(plot_file_path, plot = p, width = plot_width_mm / 25.4, height = plot_height_mm / 25.4, units = "in", device = cairo_pdf)

  # Open the saved plot file
  utils::browseURL(plot_file_path)
}

# Call the function with corrected arguments (example usage)
# bar_with_jitter(
#   csv_path = "~/Desktop/familiarity_pct_E136.csv",
#   csv_dataname = "",
#   bar_labels = c("Experiment 1", "Experiment 3", "Experiment 4"),
#   bar_colors = c("Experiment 1" = "grey40", "Experiment 3" = "grey40", "Experiment 4" = "grey40"),
#   ylabel = "% Real-life familiarity",
#   y_min = 0,
#   y_max = 105,
#   do_signif = FALSE,
#   plot_width_mm = 85,
#   plot_height_mm = 85,
#   bar_width_mm = 15
# )
