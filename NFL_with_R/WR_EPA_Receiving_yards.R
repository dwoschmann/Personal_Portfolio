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


?nflfastR

ls("package:nflfastR")

player_stats <- load_player_stats(2024)

team_logos <- load_teams() %>%
  select(team_abbr, team_logo_wikipedia) %>%
  rename(recent_team = team_abbr)

pbp <- load_pbp(2024)


wr_receiving_yards_epa <- pbp %>%
  filter(!is.na(receiving_yards) & receiving_yards != 0) %>%
  drop_na(epa, receiving_yards) %>%
  group_by(receiver, posteam) %>%
  summarise(
    total_receiving_yards = sum(receiving_yards),
    epa = sum(epa)
  ) %>%
  inner_join(player_stats, by = c("receiver" = "player_name")) %>%
  filter(position == "WR") %>%
  group_by(receiver, recent_team) %>%
  summarise(
    position = first(position),
    total_receiving_yards = sum(total_receiving_yards),
    epa = sum(epa)
  )
wr_receiving_yards_epa <- wr_receiving_yards_epa %>%
  filter(!(receiver == "D.Moore" & recent_team == "CAR"))

wr_receiving_yards_epa <- wr_receiving_yards_epa %>%
  left_join(team_logos, by = "recent_team")

view(wr_receiving_yards_epa)


ggplot(wr_receiving_yards_epa, aes(x = total_receiving_yards, y = epa)) +
  geom_image(aes(image = team_logo_wikipedia), size = 0.04) +
  geom_text_repel(
    aes(label = receiver),
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
    title = "EPA and Receiving Yards",
    subtitle = "Data: nflfastr | Chart: Daniel Oschmann",
    x = "Receiving Yards",
    y = "EPA"
  ) +
  theme_minimal() +
  theme(
    plot.margin = margin(10, 10, 10, 10)
  )
