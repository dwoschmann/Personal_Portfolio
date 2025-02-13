pbp_r <- load_pbp(2014:2024)

# Filter Only Passing Plays & Handle Missing Data
pbp_r_kelce <-
  pbp_r |>
  filter(play_type == "pass" & receiver == "T.Kelce") |>
  mutate(epa = ifelse(is.na(epa), 0, epa))  # Handle missing EPA values

# Aggregate EPA Metrics
pbp_r_kelce_epa <-
  pbp_r_kelce |>
  group_by(season, receiver_id) |>
  summarize(
    n = n(),
    epa_total = sum(epa),
    epa_per = mean(epa),
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
pbp_r_kelce_epa <- 
  pbp_r_kelce_epa |>
  inner_join(player_headshots, by = "receiver_id")

colnames(pbp_r_kelce)

kelce_epa_plot <-
  ggplot(pbp_r_kelce_epa, aes(x = season, y = epa_per)) +
  geom_line(color = "red", linewidth = .5) +  # Line for trend
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey", linewidth = .5) +  # Dashed line at y = 0
  geom_image(aes(image = headshot_url), size = 0.085) +  # Headshot for each season
  scale_x_continuous(breaks = seq(2014, 2024, 1)) +  # Show every year
  scale_y_continuous(limits = c(min(pbp_r_kelce_epa$epa_per) - 0.5, max(pbp_r_kelce_epa$epa_per) + 0.5)) +  
  labs(
    title = "Travis Kelce's Expected Points Added (EPA) Per Season",
    subtitle = "Data: nflfastR | Chart: @Dumbanalytics",
    x = "Season",
    y = "EPA Per Catch"
  ) +
  theme_minimal()

ggsave("kelce_epa_plot.png", width = 10, height = 6, dpi = 300, bg = "white")
