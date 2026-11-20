
# read in data
data <- read.csv("spei_winter_ice.csv")

data$ge95 <- ifelse(as.numeric(data$min4_bs) > 95, 1, 0)

ice_days <- aggregate(data, ge95 ~ Eider_year, FUN = sum)
