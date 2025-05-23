pbp_r <- load_pbp(2014:2024)

# Filter Only Passing Plays & Handle Missing Data
pbp_r_kelce <-
  pbp_r |>
  filter(play_type == "pass" & receiver == "T.Kelce") |>
  mutate(receiving_yards = ifelse(is.na(receiving_yards), 0, receiving_yards))

# Calculate Passing Yards Over Expected (RYOE)
yard_to_go_r <-
  lm(receiving_yards ~ 1 + ydstogo, data = pbp_r_kelce)

pbp_r_kelce <-
  pbp_r_kelce |>
  mutate(ryoe = resid(yard_to_go_r))


# Aggregate RYOE Metrics
pbp_r_kelce_ryoe <-
  pbp_r_kelce |>
  group_by(season, receiver_id) |>
  summarize(
    n = sum(complete_pass),
    ryoe_total = sum(ryoe),
    ryoe_per = mean(ryoe),
    yards_per_catch = mean(receiving_yards),
    .groups = "drop"
  ) |>
  arrange(season)

# Load Player Headshots
player_headshots <- load_player_stats(seasons = 2023:2024) |>
  select(player_id, headshot_url) |>
  rename(receiver_id = player_id) |>
  distinct(receiver_id, .keep_all = TRUE)

# Merge Headshots with Data
pbp_r_kelce_ryoe <- 
  pbp_r_kelce_ryoe |>
  inner_join(player_headshots, by = "receiver_id")

colnames(pbp_r_kelce)

kelce_ryoe_plot <-
  ggplot(pbp_r_kelce_ryoe, aes(x = season, y = ryoe_per)) +
  geom_line(color = "red", linewidth = .5) +  # Line for trend
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey", linewidth = 1) +  # Dashed line at y = 0
  geom_image(aes(image = headshot_url), size = 0.085) +  # Headshot for each season
  scale_x_continuous(breaks = seq(2013, 2024, 1)) +  # Show every year
  scale_y_continuous(limits = c(min(pbp_r_kelce_ryoe$ryoe_per) - 1, max(pbp_r_kelce_ryoe$ryoe_per) + 1)) +  
  labs(
    title = "Travis Kelce's Receiving Yards Over Expected (RYOE) Per Season",
    subtitle = "Data: nflfastR | Chart: @Dumbanalytics",
    x = "Season",
    y = "RYOE Per Catch"
  ) +
  theme_minimal()

ggsave("kelce_ryoe_plot.png", width = 10, height = 6, dpi = 300, bg = "white")
