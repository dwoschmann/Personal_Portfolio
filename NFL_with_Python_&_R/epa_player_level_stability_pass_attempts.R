install.packages(c("nflreadr", "dplyr", "tidyverse", "gt", "gtExtras", "nflfastR", "ggimage", "ggthemes", "ggtext", "ggplot2", "ggrepel"))

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

pbp_r <- load_pbp(2023:2024)

pbp_r_p <-
  pbp_r |>
  filter(play_type == 'pass' & !is.na(air_yards))

pbp_r_p <-
  pbp_r_p |>
  mutate(
    pass_length_air_yards = ifelse(air_yards >= 20, "long", "short"),
    passing_yards = ifelse(is.na(passing_yards), 0, passing_yards)
  )

pbp_r_p_s <-
  pbp_r_p |> 
  group_by(passer_player_id, passer, season) |>
  summarize( 
    n = n(),
    epa = mean(epa, na.rm = TRUE),
    .groups = "drop"
  ) |>
  filter(n >= 100) |>
  arrange(-epa) |>
  print(n = 30)

air_yards_r <-
  pbp_r_p |>
  select(passer_id, passer, season, pass_length_air_yards, passing_yards, epa) |>
  arrange(passer_id, season, pass_length_air_yards) |>
  group_by(passer_id, passer, season, pass_length_air_yards) |>
  summarize(n = n(),
            epa = mean(epa),
            .groups = "drop") |>
  filter((n >= 100 & pass_length_air_yards == "short") |
           (n >= 30 & pass_length_air_yards == "long")) |>
  select(-n)

air_yards_lag_r <-
  air_yards_r |>
  mutate(season = season + 1) |>
  rename(epa_last = epa)
        
pbp_r_p_s_pl <- 
  air_yards_r |>
  inner_join(air_yards_lag_r,
             by = c("passer_id", "pass_length_air_yards", "season", "passer")
             )

pbp_r_p_s_pl |>
  filter(!is.na(epa) & !is.na(epa_last)) |>
  group_by(pass_length_air_yards) |>
  summarize(correlation = cor(epa, epa_last))

player_headshots <- load_player_stats(seasons = 2023:2024) |>
  select(player_id, headshot_url) |>
  rename(passer_id = player_id) |>
  distinct(passer_id, .keep_all = TRUE)

pbp_r_p_s_pl <- 
  pbp_r_p_s_pl |>
  inner_join(player_headshots, by = "passer_id")


scatter_epa_r <- ggplot(pbp_r_p_s_pl, aes(x = epa_last, y = epa)) +
  geom_image(aes(image = headshot_url), size = 0.1) +
  facet_grid(cols = vars(pass_length_air_yards)) +
  labs(
    title = "QB Stability of EPA",
    subtitle = "Minimum 100 passing plays, Short Pass: < 30 Yards, Long Pass: ≥ 30 Yards | Data: NFLfastR | Chart:@dumbanalytics",
    x = "EPA per Attempt, 2023",
    y = "EPA per Attempt, 2024"
    ) +
  theme_bw() +
  geom_smooth(method = "lm")
 
scatter_epa_r
