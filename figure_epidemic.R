library(dplyr)
library(tidyr)
library(ggplot2); theme_set(theme_bw())
library(gridExtra)
source("color_palette.R")
source("theme.R")

covid2 <- read_xlsx("COVID19-Korea-2020-02-14.xlsx", sheet=2)
covid3 <- read_xlsx("COVID19-Korea-2020-02-14.xlsx", sheet=2)

covid2_gather <- covid2 %>%
  gather(key, value, -date, -`KCDC_no (https://www.cdc.go.kr/board/board.es?mid=a20501000000&bid=0015)`,
         -`date_accessed (based on Korean time)`, -`suspected cases`, -note) %>%
  mutate(
    key=factor(key, levels=c("unknown", "negative", "positive"))
  )

covid2_gather_diff <- covid2_gather %>%
  group_by(key) %>%
  mutate(
    value=diff(c(0, value))
  ) %>%
  ungroup %>%
  mutate(
    key=factor(key, levels=c("unknown", "negative", "positive"))
  )

g1 <- ggplot(covid2_gather) +
  geom_bar(aes(date, value, fill=key), stat="identity") +
  scale_x_datetime("Confirm dates") +
  scale_y_continuous("Cumulative number of cases", expand=c(0, 0)) +
  scale_fill_manual(values=cpalette) +
  btheme +
  theme(
    legend.title=element_blank(),
    legend.position="top"
  )

g1_sub <- (g1 %+% filter(covid2_gather, key=="positive")) +
  theme(legend.position="none")  +
  scale_fill_manual(values=cpalette[3]) 

g2 <- ggplot(covid2_gather_diff) +
  geom_hline(yintercept=0, lty=2) +
  geom_bar(aes(date, value, fill=key), stat="identity", position="dodge") +
  scale_x_datetime("Confirmed dates") +
  scale_y_continuous("Daily number of cases", expand=c(0, 0)) +
  scale_fill_manual(values=cpalette)  +
  btheme +
  theme(
    legend.title=element_blank(),
    legend.position="top"
  )

g2_sub <- (g2 %+% filter(covid2_gather_diff, key=="positive")) +
  theme(legend.position="none") +
  scale_fill_manual(values=cpalette[3]) 

g3 <- g1 + annotation_custom(ggplotGrob(g1_sub), xmin = as.POSIXct("2020-01-18"), xmax = as.POSIXct("2020-02-05"), 
                  ymin = 2650, ymax = 5300)

g4 <- g2 + annotation_custom(ggplotGrob(g2_sub), xmin = as.POSIXct("2020-01-18"), xmax = as.POSIXct("2020-02-05"), 
                             ymin = 300, ymax = 1000)

gtot <- arrangeGrob(g3, g4, nrow=1)

# ggsave("figure_epidemic.pdf", gtot, width=10, height=5)
ggsave("figure_epidemic.png", gtot, width=10, height=5)