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


player_stats <- load_player_stats(2023)

team_logos <- load_teams() %>%
  select(team_abbr, team_logo_wikipedia) %>%
  rename(recent_team = team_abbr)  # Rename column to match player stats

sacks_rush_epa_QB <- player_stats %>%
  filter(position == "QB") %>%
  filter(!is.na(sack_yards) & sack_yards != 0) %>%
  drop_na(rushing_epa, sack_yards) %>%
  group_by(player_name, recent_team) %>%
  summarise(
    position = first(position),
    total_sack_yards = sum(sack_yards),
    rushing_epa = sum(rushing_epa),
    attempts = sum(attempts)
  ) %>%
  filter(attempts >= 100)


sacks_rush_epa_QB <- sacks_rush_epa_QB %>%
  left_join(team_logos, by = "recent_team")


ggplot(sacks_rush_epa_QB, aes(x = total_sack_yards, y = rushing_epa)) +
  geom_image(aes(image = team_logo_wikipedia), size = 0.035) +
  geom_text(
    aes(label = player_name),
    size = 3,
    vjust = -0.5,
    hjust = -0.2,
    nudge_x = 0.5
  ) +  
  labs(
    title = "Scatter Plot of Rushing EPA vs. Total Sack Yards",
    subtitle = "Min 100 attempts | Data: nflfastr | Chart: Daniel Oschmann",
    x = "Total Sack Yards",
    y = "Rushing EPA"
  ) +
  scale_y_continuous(limits = c(-30, 60)) +
  scale_x_continuous(limits = c(-10, max(sacks_rush_epa_QB$total_sack_yards) + 10)) +
  theme_minimal() +
  theme(
    plot.margin = margin(10, 10, 10, 10)
  )
