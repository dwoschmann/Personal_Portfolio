library(nflreadr)
library(dplyr)
library(tidyverse)
library(gt)
library(gtExtras)
library(nflfastR)
library(ggimage)
library(ggthemes)
library(ggtext)
library(ggplot2)
library(ggrepel)

qb_cpoe <- read_csv()
print(qb_cpoe)

# Load Team Logos
team_logos <- load_teams() |>
  select(team_abbr, team_logo_wikipedia) |>
  rename(posteam = team_abbr)

# Merge Logos with Data
qb_cpoe <- 
  qb_cpoe |>
  inner_join(team_logos, by = "posteam")


mean_compl <- mean(qb_cpoe$compl, na.rm = TRUE)
mean_cpoe <- mean(qb_cpoe$cpoe, na.rm = TRUE)

qb_cpoe_plot <-
  ggplot(data = qb_cpoe, aes(x = cpoe, y = compl)) +
  geom_image(aes(image = team_logo_wikipedia), size = 0.07) +
  geom_text_repel(
    aes(label = passer),
    size = 3, 
    box.padding = 0.3,
    point.padding = 0.2,
    max.overlaps = 30,
    min.segment.length = 0.5,
    force = 2
  ) +
  geom_hline(yintercept = mean_compl, linetype = "dashed", color = "gray30") +
  scale_x_continuous(labels = scales::percent_format(scale = 1)) +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  labs(
    title = "QBs: Completion Percentage vs Completion Percentage Above/Below Excpeted",
    x = "CPOE",
    y = "Completion %",
    caption = "Data: nflfastR | Chart: @dumb_analytics"
  ) +
  theme_minimal()

ggsave("qb_cpoe_plot.png", width = 10, height = 6, dpi = 300, bg = "white")
