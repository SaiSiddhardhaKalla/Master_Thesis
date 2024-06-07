library(ggplot2)

df1 <- read.csv('/Users/sid/Desktop/2017gini.csv')
df2 <- read.csv('/Users/sid/Desktop/2020gini.csv')

####################################################################
# Filter the data
filtered_df <- df1[df1$num > 2, ]
filtered_df <- filtered_df[filtered_df$alesina > 0, ]
filtered_df <- filtered_df[filtered_df$subdist_ntl_pc <= 0.6, ]
# Create the scatter plot with a quadratic best fit line
ggplot(filtered_df, aes(x = subdist_ntl_pc, y = alesina)) +
  geom_point() +  # Add points
  geom_smooth(method = "lm", formula = y ~ poly(x, 2), se = FALSE) +  # Add a quadratic model (best fit line) without confidence interval
  scale_y_continuous(limits = c(-0.05, 1.05)) +  # Set y-axis range
  # scale_x_continuous(limits = c(-0.05, 2)) + 
  labs(x = "Subdist NTL PC", y = "Alesina") +  # Label the axes
  theme_minimal()# Use a minimal theme
####################################################################

# Filter the first data frame
filtered_df1 <- df1[df1$num > 2 & df1$alesina > 0 & df1$subdist_ntl_pc <= 0.2, ]
# Filter the second data frame
filtered_df2 <- df2[df2$num > 2 & df2$alesina > 0 & df2$subdist_ntl_pc <= 0.2, ]

# Create the scatter plot with a quadratic best fit line for both data frames
ggplot() +
  geom_point(data = filtered_df1, aes(x = subdist_ntl_pc, y = alesina), color = 'blue') +  # Add points for df1
  geom_smooth(data = filtered_df1, aes(x = subdist_ntl_pc, y = alesina), method = "lm", formula = y ~ poly(x, 2), se = FALSE, color = 'blue') +  # Add quadratic model for df1
  geom_point(data = filtered_df2, aes(x = subdist_ntl_pc, y = alesina), color = 'red') +  # Add points for df2
  geom_smooth(data = filtered_df2, aes(x = subdist_ntl_pc, y = alesina), method = "lm", formula = y ~ poly(x, 2), se = FALSE, color = 'red') +  # Add quadratic model for df2
  scale_y_continuous(limits = c(-0.05, 1.05)) +  # Set y-axis range
  # scale_x_continuous(limits = c(-0.05, 2)) +  
  labs(x = "Subdist NTL PC", y = "Alesina", color = "Year") +  # Label the axes and legend
  scale_color_manual(values = c("2017" = "blue", "2020" = "red")) +# Label the axes
  theme_minimal()  # Use a minimal theme

####################################################################


# Select only the necessary columns and filter the first data frame
filtered_df1 <- df1[df1$num > 2 & df1$alesina > 0 & df1$subdist_ntl_pc <= 0.2, c("subdist_ntl_pc", "alesina")]
filtered_df1$year <- "2017"  # Add a column for the year

# Select only the necessary columns and filter the second data frame
filtered_df2 <- df2[df2$num > 2 & df2$alesina > 0 & df2$subdist_ntl_pc <= 0.2, c("subdist_ntl_pc", "alesina")]
filtered_df2$year <- "2020"  # Add a column for the year

# Combine the two data frames
combined_df <- rbind(filtered_df1, filtered_df2)

# Create the scatter plot with a quadratic best fit line for both data frames
ggplot(combined_df, aes(x = subdist_ntl_pc, y = alesina, color = year)) +
  geom_point() +  # Add points
  geom_smooth(method = "lm", formula = y ~ poly(x, 2), se = FALSE) +  # Add quadratic model
  scale_y_continuous(limits = c(-0.01, 1.01)) +  # Set y-axis range
  # scale_x_continuous(limits = c(-0.05, 2)) +  # Uncomment if you want to set x-axis range
  labs(x = "Subdist NTL per capita (Rural Sub-district)", y = "Gini", color = "Year") +  # Label the axes and legend
  scale_color_manual(values = c("2017" = "blue", "2020" = "red")) +  # Set custom colors
  theme_classic() + # Use a minimal theme
  theme(legend.position = "bottom") 


