pbp_r_rec <-
  pbp_r |>
  filter(play_type == "pass" & !is.na(receiver_id)) |>
  mutate(receiving_yards = ifelse(is.na(receiving_yards), 0, receiving_yards))

# Calculate Passing Yards Over Expected (RYOE)
yard_to_go_r <-
  lm(receiving_yards ~ 1 + ydstogo, data = pbp_r_rec)

pbp_r_rec <-
  pbp_r_rec |>
  mutate(ryoe = resid(yard_to_go_r))

# Get Team Each receiver Played for Per Season
receiver_teams <- pbp_r_rec |>
  group_by(season, receiver_id, receiver, posteam) |>
  summarize(n = n(), .groups = "drop") |>
  arrange(season, receiver_id, desc(n)) |>
  distinct(season, receiver_id, receiver, .keep_all = TRUE) |>
  select(season, receiver_id, receiver, posteam)

# Aggregate RYOE Metrics
ryoe_r <-
  pbp_r_rec |>
  group_by(season, receiver_id, receiver) |>
  summarize(
    n = n(),
    ryoe_total = sum(ryoe),
    ryoe_per = mean(ryoe),
    yards_per_catch = mean(receiving_yards),
    .groups = "drop"
  ) |>
  arrange(-ryoe_total) |>
  filter(n > 30) |>  # Filter for players with more than 530 receptions
  inner_join(receiver_teams, by = c("season", "receiver_id", "receiver"))

# Create Lagged Data for Year-over-Year Analysis
ryoe_now_r <-
  ryoe_r |>
  select(-n, -ryoe_total)

ryoe_last_r <-
  ryoe_r |>
  select(-n, -ryoe_total) |>
  mutate(season = season + 1) |>
  rename(
    ryoe_per_last = ryoe_per,
    yards_per_catch_last = yards_per_catch,
    posteam_last = posteam  # Rename for clarity
  )

# Join Data for Year-over-Year Comparison
ryoe_lag_r <-
  ryoe_now_r |>
  inner_join(ryoe_last_r, by = c("receiver_id", "receiver", "season")) |>
  ungroup()

# Filter Players who Changed Teams or Stayed with the Same Team
ryoe_lag_r <- ryoe_lag_r |>
  mutate(changed_team = posteam != posteam_last)

# Manually set A.Cooper's changed_team flag to TRUE
ryoe_lag_r <- ryoe_lag_r |>
  mutate(changed_team = ifelse(receiver == "A.Cooper", TRUE, changed_team))

# Load Player Headshots
player_headshots <- load_player_stats(seasons = 2023:2024) |>
  select(player_id, headshot_url) |>
  rename(receiver_id = player_id) |>
  distinct(receiver_id, .keep_all = TRUE)

# Merge Headshots with Data
ryoe_lag_r <- 
  ryoe_lag_r |>
  inner_join(player_headshots, by = "receiver_id")


ryoe_plot_on_new_teams <-
  ggplot(ryoe_lag_r |> filter(changed_team == TRUE), aes(x = ryoe_per_last, y = ryoe_per)) +
  geom_image(aes(image = headshot_url), size = 0.1) +
  labs(title = "RYOE Per Reception: 2023 vs. 2024 | Players who switched teams in 2024",
       subtitle = "Minimum 30 catches both seasons | Data: nflfastR | Chart: @dumbanalytics",
       x = "RYOE Per Reception 2023",
       y = "RYOE Per Reception 2024") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black") +
  theme_minimal()

ggsave("ryoe_plot_on_new_teams_receiving.png", width = 10, height = 6, dpi = 300, bg = "white")

ryoe_plot_on_same_teams <-
  ggplot(ryoe_lag_r |> filter(changed_team == FALSE), aes(x = ryoe_per_last, y = ryoe_per)) +
  geom_image(aes(image = headshot_url), size = 0.1) +
  labs(title = "RYOE Per Reception: 2023 vs. 2024 | Players who stayed with team in 2024",
       subtitle = "Minimum 30 catches both seasons | Data: nflfastR | Chart: @dumbanalytics",
       x = "RYOE Per Reception 2023",
       y = "RYOE Per Reception 2024") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black") +
  theme_minimal()

ggsave("ryoe_plot_on_same_teams_receiving.png", width = 10, height = 6, dpi = 300, bg = "white")
