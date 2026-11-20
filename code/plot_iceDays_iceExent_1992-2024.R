# R code to plot ice days and Bering Sea median daily sea ice extent over 1992-2025

# got packages
library(ggplot2)

# load data
extent <- read.csv("output/summary_ice_extent_daily_bering_sea_1992-2025.csv")
days <- read.csv("output/sic_beringSea_4pixels/sea_ice_vars_1992_2025.csv")

# wrangle data to rbind
ext_med <- extent[c("year_winter", "median_extent_km2")]
colnames(ext_med) <- c("year_winter", "value")
ext_med$variable <- "ice_extent"
ext_med$value <- ext_med$value/10000 # scale to make values similar range

ice_days_ws <- days[c("year_winter", "ws_count_sic_ge95")]
colnames(ice_days_ws) <- c("year_winter", "value")
ice_days_ws$variable <- "ice_days"

ice_all <- rbind.data.frame(ice_days_ws, ext_med)

# plot
p.ice <- ggplot(data = ice_all, aes(x = year_winter, y = value, group = variable, linetype = variable)) +
  geom_line() +
  scale_linetype_discrete( name = "Ice Variables",labels = c("Ice Days (count)", "Ice Extent Median (km^2)")) +
  labs(x = "Winter Year", y = "Ice Variable Value") +
  scale_x_continuous(breaks = seq(1992, 2024, by = 5)) +
  annotate("rect", xmin = 2015, xmax = 2018, ymin = -Inf, ymax = Inf, fill = "red", alpha = 0.2) +
  annotate("rect", xmin = 2019.9, xmax = 2020.2, ymin = -Inf, ymax = Inf, fill = "red", alpha = 0.2) +
  #geom_vline(xintercept = 2020, color = "red", alpha = 0.2) +  
  theme_bw()
p.ice

ggsave(paste0("output/figs/plot_iceDays_iceExtent_", Sys.Date(), ".jpg"),
       plot = p.ice,
       width = 6,
       height = 4,
       units = "in",
       dpi = 300)

# scatter plot
# put data in wide format via merge
ice_wide <- merge(extent, days, by = "year_winter")

# look at correlation
correlation <- cor.test(ice_wide$mean_extent_km2, ice_wide$ws_count_sic_ge95)
correlation

# plot scatter
p.scatter <- ggplot(data = ice_wide, aes(x = mean_extent_km2, y = ws_count_sic_ge95)) +
  geom_point() +
  theme_bw()
p.scatter
