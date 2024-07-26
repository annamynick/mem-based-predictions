# Load the ggplot2 library
library(ggplot2)
library(extrafont)
# font_import(pattern = "Arial", prompt = FALSE)
# loadfonts(device = "pdf")  # Use 'pdf' for PDF devices

# Change current working directory 
setwd("~/Dropbox_Lab/projects/pattern-completion/analysis-scripts-CB-s2/memory-based-predictions/analysis-scripts/")

pilot_name = "Pilot B"
file_path <- paste0('./rp_', gsub(" ", "", pilot_name), '.csv')
data <- read.csv(file_path, header = FALSE)

# Calculate the maximum value in the data matrix
max_value <- max(data)

# Calculate the top limit for the Y-axis
y_top = 1.6
y_bottom = .6

# Create a data frame for plotting
df <- data.frame(
  Condition = factor(1:ncol(data), labels=c("Same-scene", "Neutral")),
  Mean = colMeans(data)
)

# Create a data frame for the individual observations
obs_df <- data.frame(
  Observation = rep(1:nrow(data), each=ncol(data)),
  Condition = factor(rep(1:ncol(data), times=nrow(data)), labels=c("Same-scene", "Neutral")),
  Value = as.vector(t(data))
)

# Convert bar width from mm to inches
bar_width_mm <- 10
bar_width_inches <- bar_width_mm / 25.4

# Define custom hex colors for the bars
custom_colors <- c("Same-scene" = "#136289", "Neutral" = "#5d88a4")

# Plot
plot <- ggplot() +
  geom_bar(data=df, aes(x=Condition, y=Mean, fill=Condition), stat="identity", width=bar_width_inches) +  # Set bar width to 10mm
  geom_line(data=obs_df, aes(x=Condition, y=Value, group=Observation), color="#d3d3d3", size=0.5, alpha=0.5) +  # Add lines for individual observations
  geom_point(data=obs_df, aes(x=Condition, y=Value, group=Observation), color="#d3d3d3", size=1.5, shape=1) +  # Add open circle points for individual observations
  scale_fill_manual(values = custom_colors) +  # Set custom hex colors for the bars
  coord_cartesian(ylim = c(y_bottom, y_top)) +  # Manually set Y-axis limits
  labs(title=pilot_name,
       x=NULL,
       y="Response Time (s)") +  # Remove y-axis label
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(),  # Remove major grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    panel.background = element_blank(),  # Remove background
    axis.line = element_line(color = "black"),  # Add axis lines
    axis.ticks.y = element_line(color = "black"),  # Add y-axis tick marks
    text = element_text(family = "Arial", color = "black"),  # Set font to 'sans' and color to black
    plot.title = element_text(size = 7, face = "bold", color = "black"),
    axis.title = element_text(size = 7, color = "black"),
    axis.text = element_text(size = 7, color = "black"),  # Explicitly set axis text color to black
    legend.position = "none",  # Hide legend
    plot.margin = unit(c(0, 0, 0, 0), "cm")  # Remove all plot margins
  )

# Save plot with specified dimensions and format
plot_width_mm <- 54.67
plot_height_mm <- 54.67
plot

save_path <- paste0('~/Desktop/', pilot_name, '.pdf')
ggsave(save_path, plot, width = plot_width_mm / 25.4, height = plot_height_mm / 25.4, units = "in", device = cairo_pdf)
