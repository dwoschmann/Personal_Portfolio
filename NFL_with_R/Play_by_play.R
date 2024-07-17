install.packages(c("nflreadr", "tidyverse", "gt", "gtExtras", "nflfastR", "ggimage", "ggthemes", "ggtext"))

library(nflreadr)
library(tidyverse)
library(gt)
library(gtExtras)
library(nflfastR)
library(ggimage)
library(ggthemes)
library(ggtext)


pbp_data <- load_pbp(2023)
teams <- unique(pbp_data$posteam)

team_pbp <- pbp_data %>%
  filter(!is.na(posteam) & posteam != "unknown" &
           !is.na(defteam) & defteam != "unknown")

team_summary <- team_pbp %>%
  group_by(posteam) %>%
  summarise(
    run_play_count = sum(play_type == "run", na.rm = TRUE),
    pass_play_count = sum(play_type == "pass", na.rm = TRUE),
    total_plays = n(),
    run_ratio = sum(sum(play_type == "run", na.rm = TRUE) / total_plays)
  )
