install.packages(c("nflreadr", "tidyverse", "gt", "gtExtras", "nflfastR", "ggimage", "ggthemes", "ggtext", "ggplot2", "ggrepel"))

library(nflreadr)
library(tidyverse)
library(gt)
library(gtExtras)
library(nflfastR)
library(ggimage)
library(ggthemes)
library(ggtext)
library(ggplot2)
library(ggrepel)


player_stats <- load_player_stats(2024)

team_logos <- load_teams() %>%
  select(team_abbr, team_logo_wikipedia) %>%
  rename(recent_team = team_abbr)

pbp <- load_pbp(2024)

colnames(player_stats)
colnames(pbp)


qb_passing_yards_qb_epa <- pbp %>%
  filter(!is.na(passing_yards) & passing_yards != 0) %>%
  drop_na(qb_epa, passing_yards) %>%
  group_by(passer_player_name, posteam) %>%
  summarise(
    total_passing_yards = sum(passing_yards),
    qb_epa = sum(qb_epa)
  ) %>%
  inner_join(player_stats, by = c("passer_player_name" = "player_name")) %>%
  filter(position == "QB") %>%
  group_by(passer_player_name, recent_team) %>%
  summarise(
    position = first(position),
    total_passing_yards = sum(total_passing_yards),
    qb_epa = sum(qb_epa)
  )

qb_passing_yards_qb_epa <- qb_passing_yards_qb_epa %>%
  left_join(team_logos, by = "recent_team")


view(qb_passing_yards_qb_epa)


ggplot(qb_passing_yards_qb_epa, aes(x = total_passing_yards, y = qb_epa)) +
  geom_image(aes(image = team_logo_wikipedia), size = 0.04) +
  geom_text_repel(
    aes(label = passer_player_name),
    size = 3,
    box.padding = 0.2,
    point.padding = 0.2,
    segment.size = 0.2,
    min.segment.length = 0,
    nudge_y = 0.2,
    nudge_x = 0.2,
    max.overlaps = Inf
  ) +  
  labs(
    title = "QB EPA and Passing Yards",
    subtitle = "Through Week 1 | Data: nflfastr | Chart: Daniel Oschmann",
    x = "Passing Yards",
    y = "EPA"
  ) +
  theme_minimal() +
  theme(
    plot.margin = margin(10, 10, 10, 10)
  )
