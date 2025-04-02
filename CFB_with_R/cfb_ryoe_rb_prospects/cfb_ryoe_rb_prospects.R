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

running_backs <- cfbd_team_roster(2024, team = NULL) |>
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

ryoe_r <- pbp_r_run |>
  group_by(rusher_player_name) |>
  summarize(
    carries = n(),
    ryoe_total = sum(ryoe),
    ryoe_per = mean(ryoe),
    total_yards = sum(yds_rushed),
    yards_per_carry = mean(yards_gained),
  )

team_info <- cfbd_team_info() |>
  select(school, logo, color) |>
  rename(team = school)

ryoe_r_rb <- inner_join(runningbacks, ryoe_r, by = "rusher_player_name") |>
  inner_join(team_info, by = "team") |>
  select(rusher_player_name, team, logo, color, carries, ryoe_total, ryoe_per, total_yards, yards_per_carry)  # Select only needed columns

ryoe_r_rb <- ryoe_r_rb |>
  arrange(desc(ryoe_total))

rb_prospects <- tibble(
  rusher_player_name = player_names <- c(
    "Ashton Jeanty",
    "Omarion Hampton",
    "Bhayshul Tuten",
    "Quinshon Judkins",
    "TreVeyon Henderson",
    "RJ Harvey",
    "Brashard Smith",
    "Jarquez Hunter",
    "Kaleb Johnson",
    "Corey Kiner",
    "Damien Martinez",
    "Dylan Sampson",
    "DJ Giddens",
    "Tahj Brooks",
    "Ollie Gordon II",
    "Cam Skattebo",
    "Kalel Mullings",
    "Kyle Monangai",
    "Jordan James")
)
  
ryoe_r_rb_prospects <- ryoe_r_rb |>
  semi_join(rb_prospects, by = "rusher_player_name")


cfb_ryoe_total_bar_plot <- ggplot(ryoe_r_rb_prospects, aes(x = ryoe_total, y = reorder(rusher_player_name, ryoe_total), fill = color)) + 
  geom_col(width = 0.5, show.legend = FALSE, alpha = 0.75) +
  geom_image(aes(image = logo), size = 0.06) +
  scale_fill_identity() +
  labs(
    title = "Total Rushing Yards Over Expected - 2024",
    subtitle = "2025 RB Prospects",
    x = "Total RYOE",
    y = "",
    caption = "Data: cfbfastR | Chart: @dumb_analytics"
  ) +
  theme_minimal() +
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.y = element_text(size = 10, face = "bold"),
    axis.text.x = element_text(size = 10),
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 12, color = "gray40"),
    plot.caption = element_text(size = 10, color = "gray50")
  )

ggsave("cfb_ryoe_total_bar_plot.png", width = 10, height = 6, dpi = 300, bg = "white")


cfb_ryoe_per_bar_plot <- ggplot(ryoe_r_rb_prospects, aes(x = ryoe_per, y = reorder(rusher_player_name, ryoe_per), fill = color)) + 
  geom_col(width = 0.5, show.legend = FALSE, alpha = 0.75) +
  geom_image(aes(image = logo), size = 0.06) +
  scale_fill_identity() +
  labs(
    title = "Rushing Yards Over Expected Per Carry - 2024",
    subtitle = "2025 RB Prospects",
    x = "RYOE Per Carry",
    y = "",
    caption = "Data: cfbfastR | Chart: @dumb_analytics"
  ) +
  theme_minimal() +
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.y = element_text(size = 10, face = "bold"),
    axis.text.x = element_text(size = 10),
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 12, color = "gray40"),
    plot.caption = element_text(size = 10, color = "gray50")
  )

ggsave("cfb_ryoe_per_bar_plot.png", width = 10, height = 6, dpi = 300, bg = "white")
