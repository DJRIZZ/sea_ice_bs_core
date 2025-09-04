# create plot of extreme_hi and extreme_lo (counts of days >95% and days <16% ice each year, with year=winter_year)

# packages
library(ggplot2)

# load data
ice<-read.csv("output/winter_ice_1978_2019.csv", header=T)

#transform hi and lo ice into long format dataframe

hilo_wide<-ice[, 2:4]
hilo<-reshape(hilo_wide, 
              direction="long",
              varying=list(names(hilo_wide)[2:3]),
              v.names="Days",
              idvar="year")
hilo$ice<-ifelse(hilo$time==1, "High", "Low")

#create plot

p.ice<-ggplot(hilo, aes(x=year, y=Days))+
  geom_line(aes(color=ice))+
  xlab("Year (Dec-Apr)")+
  ylab("Count of Days")+
  theme_bw()+
  scale_colour_manual(labels = c("No. Days > 95% ice", "No. Days < 15% ice"), values = c("blue", "red"))+
  scale_x_continuous(breaks=round(seq(min(hilo$year), max(hilo$year), by=5),1))+
  labs(color="Ice Cover in SPEI Core Area")+
  theme(axis.text.x = element_text(size = 4),
        axis.text.y = element_text(size = 4),
        axis.title=element_text(size=6),
        axis.ticks.length=unit(0.02, "cm"),
        legend.title = element_text(size=6, color = "black", face="bold"),
        legend.text = element_text(size=6),
        legend.justification=c(0,1), 
        #legend.position="top",
        legend.position=c(0.03,0.98),
        #legend.direction="vertical",
        legend.background = element_blank(),
        legend.key = element_blank(),
        plot.title=element_text(size=6, face="bold"))
p.ice

ggsave("output/fig_ice_hi_lo_year.jpg",
         width=10, height=6, units="cm", dpi=500)

hi_only<-subset(hilo, ice=="High")

p.hi<-ggplot(hi_only, aes(x=year, y=Days))+
  geom_line( color="blue")+
  xlab("Year (Dec-Apr)")+
  ylab("Count of Days")+
  theme_bw()+
  #scale_colour_manual(labels = "No. Days > 95% ice", color="blue")+
  scale_x_continuous(breaks=round(seq(min(hi_only$year), max(hi_only$year), by=5),1))+
  scale_y_continuous(limits=c(0, 150))+
  labs(color="Ice Cover in SPEI Core Area")+
  theme(axis.text.x = element_text(size = 4),
        axis.text.y = element_text(size = 4),
        axis.title=element_text(size=6),
        axis.ticks.length=unit(0.02, "cm"),
        legend.title = element_text(size=6, color = "black", face="bold"),
        legend.text = element_text(size=6),
        legend.justification=c(0,1), 
        #legend.position="top",
        legend.position=c(0.03,0.98),
        #legend.direction="vertical",
        legend.background = element_blank(),
        legend.key = element_blank(),
        plot.title=element_text(size=6, face="bold"))
p.hi

ggsave("output/fig_ice_hi_only_year.jpg",
       width=10, height=6, units="cm", dpi=500)
