pbp_r <- load_pbp(2024)

# Filter Only Rushing Plays & Handle Missing Data
pbp_r_run <-
  pbp_r |>
  filter(play_type == "run" & !is.na(rusher_id)) |>
  mutate(
    rushing_yards = ifelse(is.na(rushing_yards), 0, rushing_yards),
    epa = ifelse(is.na(epa), 0, epa)  # Ensure EPA has no missing values
  )

# Calculate Rushing Yards Over Expected (RYOE)
yard_to_go_r <-
  lm(rushing_yards ~ 1 + ydstogo, data = pbp_r_run)

pbp_r_run <-
  pbp_r_run |>
  mutate(ryoe = resid(yard_to_go_r))

# Aggregate RYOE & EPA Metrics
ryoe_epa_r <-
  pbp_r_run |>
  group_by(rusher_id, rusher) |>
  summarize(
    n = n(),
    ryoe_total = sum(ryoe),
    ryoe_per = mean(ryoe),
    epa_total = sum(epa),          # Total EPA
    epa_per = mean(epa),           # EPA per rush
    yards_per_carry = mean(rushing_yards),
    .groups = "drop"
  ) |>
  arrange(-ryoe_total) |>
  filter(n > 75)

# Load Player Headshots
player_headshots <- load_player_stats(seasons = 2023:2024) |>
  select(player_id, headshot_url) |>
  rename(rusher_id = player_id) |>
  distinct(rusher_id, .keep_all = TRUE)

# Merge Headshots with Data
ryoe_epa_r <- 
  ryoe_epa_r |>
  inner_join(player_headshots, by = "rusher_id")


ryoe_epa_plot <-
  ggplot(ryoe_epa_r, aes(x = epa_per, y = ryoe_per)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey", linewidth = 0.5) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey", linewidth = 0.5) +
  geom_image(aes(image = headshot_url), size = 0.09) +  # Player headshots as points
  geom_image(data = ryoe_epa_r %>% filter(rusher == "J.Cook"), 
             aes(x = epa_per, y = ryoe_per, image = headshot_url), 
             size = 0.1) +
  geom_point(data = ryoe_epa_r %>% filter(rusher == "J.Cook"), 
             aes(x = epa_per, y = ryoe_per),
             shape = 1, size = 12, color = "red", stroke = 1.5) +
  geom_point(data = ryoe_epa_r %>% filter(rusher == "R.Davis"), 
             aes(x = epa_per, y = ryoe_per),
             shape = 1, size = 12, color = "red", stroke = 1.5) +
  labs(
    title = "RYOE & EPA Per Carry (2024 Season) | Minimum 75 Carries",
    x = "EPA per Carry",
    y = "RYOE per Carry",
    caption = "Data: nflfastR | Chart: @dumb_analytics"
  ) +
  theme_minimal()

ggsave("ryoe_epa_plot.png", width = 10, height = 6, dpi = 600, bg = "white")
