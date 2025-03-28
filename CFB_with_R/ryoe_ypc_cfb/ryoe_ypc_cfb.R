library(dplyr)
library(tidyverse)
library(gt)
library(gtExtras)
library(cfbfastR)
library(ggimage)
library(ggthemes)
library(ggtext)
library(ggplot2)
library(ggrepel)


runningbacks <- cfbd_team_roster(2024, team = NULL) |>
  mutate(rusher_player_name = paste(first_name, last_name)) |>
  select(rusher_player_name, position, team) |>
  filter(position == "RB")


pbp_r <- load_cfb_pbp(2024)

pbp_r_run <- pbp_r |> 
  filter(!is.na(yds_rushed)) |>
  mutate(yds_rushed = ifelse(is.na(yds_rushed), 0, yds_rushed))


pbp_r_run <- pbp_r_run |> 
  drop_na(down, yard_line, score_diff)

expected_yards_rushing_r <- lm(
  yds_rushed ~ 1 + down + yard_line + score_diff + down:yard_line,
  data = pbp_r_run
)

pbp_r_run <-
  pbp_r_run |>
  mutate(ryoe = resid(expected_yards_rushing_r))


print(summary(expected_yards_rushing_r))

ryoe_r <- pbp_r_run |>
  group_by(rusher_player_name) |>
  summarize(
    carries = n(),
    ryoe_total = sum(ryoe),
    ryoe_per = mean(ryoe),
    total_yards = sum(yds_rushed),
    yards_per_carry = mean(yards_gained),
  ) |>
  filter(carries > 150)

ryoe_r_rb <- inner_join(runningbacks, ryoe_r, by = "rusher_player_name")


team_info <- cfbd_team_info() |>
  select(school, logo) |>
  rename(team = school)

ryoe_r_rb <- inner_join(team_info, ryoe_r_rb, by = "team")


x_mid <- mean(ryoe_r_rb$ryoe_per, na.rm = TRUE)
y_mid <- mean(ryoe_r_rb$yards_per_carry, na.rm = TRUE)

cfb_ryoe_r_rb_plot <-
  ggplot(data = ryoe_r_rb, aes(x = ryoe_per , y = yards_per_carry)) +
  geom_image(aes(image = logo), size = 0.07) +
  geom_text_repel(
    aes(label = rusher_player_name),
    size = 3, 
    box.padding = 0.3,
    point.padding = 0.2,
    max.overlaps = 30,
    min.segment.length = 0.5,
    force = 2
  ) +
  labs(title = "RYOE vs YPC: 2024",
       x = "RYOE Per Carry",
       y = "Yards Per Carry",
       caption = "Data: cfbfastR | Chart: @dumb_analytics"
  ) +
  geom_hline(yintercept = y_mid, linetype = "dashed", color = "black") +
  geom_vline(xintercept = x_mid, linetype = "dashed", color = "black") +
  theme_minimal()
