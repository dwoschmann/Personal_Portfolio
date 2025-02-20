pbp_r <- load_pbp(2023:2024)

# Filter Only Rushing Plays & Handle Missing Data
pbp_r_run <-
  pbp_r |>
  filter(play_type == "run" & !is.na(rusher_id)) |>
  mutate(rushing_yards = ifelse(is.na(rushing_yards), 0, rushing_yards))

# Calculate Rushing Yards Over Expected (RYOE)
yard_to_go_r <-
  lm(rushing_yards ~ 1 + ydstogo, data = pbp_r_run)

pbp_r_run <-
  pbp_r_run |>
  mutate(ryoe = resid(yard_to_go_r))

# Get Most Frequent Team Each Rusher Played for Per Season
rusher_teams <- pbp_r_run |>
  group_by(season, rusher_id, rusher, posteam) |>
  summarize(n = n(), .groups = "drop") |>
  arrange(season, rusher_id, desc(n)) |>
  distinct(season, rusher_id, rusher, .keep_all = TRUE) |>
  select(season, rusher_id, rusher, posteam)

# Aggregate RYOE Metrics
ryoe_r <-
  pbp_r_run |>
  group_by(season, rusher_id, rusher) |>
  summarize(
    n = n(),
    ryoe_total = sum(ryoe),
    ryoe_per = mean(ryoe),
    yards_per_carry = mean(rushing_yards),
    .groups = "drop"
  ) |>
  arrange(-ryoe_total) |>
  filter(n > 50, !rusher %in% c("J.Hurts", "L.Jackson", "J.Allen")) |>
  inner_join(rusher_teams, by = c("season", "rusher_id", "rusher"))

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
    yards_per_carry_last = yards_per_carry,
    posteam_last = posteam  # Rename for clarity
  )

# Join Data for Year-over-Year Comparison
ryoe_lag_r <-
  ryoe_now_r |>
  inner_join(ryoe_last_r, by = c("rusher_id", "rusher", "season")) |>
  ungroup()

# Filter Players who Changed Teams or Stayed with the Same Team
ryoe_lag_r <- ryoe_lag_r |>
  mutate(changed_team = posteam != posteam_last)

# Load Team Logos
team_logos <- load_teams() |>
  select(team_abbr, team_logo_wikipedia) |>
  rename(posteam = team_abbr)

# Merge Logos with Data
ryoe_lag_r <- 
  ryoe_lag_r |>
  inner_join(team_logos, by = "posteam")


ryoe_plot_on_new_teams <-
  ggplot(ryoe_lag_r |> filter(changed_team == TRUE), aes(x = ryoe_per_last, y = ryoe_per)) +
  geom_image(aes(image = team_logo_wikipedia), size = 0.05) +
  geom_text_repel(
    aes(label = rusher),
    size = 3, 
    box.padding = 0.3, 
    max.overlaps = 10,
    min.segment.length = 0.5,
    force = 0.5
  )+
  scale_y_continuous(limits = c(-2, 2)) +
  labs(title = "RYOE Per Attempt: 2023 vs. 2024 | Players who switched teams in 2024",
       subtitle = "Minimum 50 carries both seasons",
       x = "RYOE Per Attempt 2023",
       y = "RYOE Per Attempt 2024",
       caption = "Data: nflfastR | Chart: @dumb_analytics"
       ) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black") +
  theme_minimal()

ggsave("ryoe_plot_on_new_teams.png", width = 10, height = 6, dpi = 300, bg = "white")

ryoe_plot_on_same_teams <-
  ggplot(ryoe_lag_r |> filter(changed_team == FALSE), aes(x = ryoe_per_last, y = ryoe_per)) +
  geom_image(aes(image = team_logo_wikipedia), size = 0.05) +
  geom_text_repel(
    aes(label = rusher),
    size = 3, 
    box.padding = 0.3, 
    max.overlaps = 10,
    min.segment.length = 0.5,
    force = 0.5
  )+
  labs(title = "RYOE Per Attempt: 2023 vs. 2024 | Players who stayed with team in 2024",
       subtitle = "Minimum 50 carries both seasons",
       x = "RYOE Per Attempt 2023",
       y = "RYOE Per Attempt 2024",
       caption = "Data: nflfastR | Chart: @dumb_analytics"
       ) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black") +
  theme_minimal()

ggsave("ryoe_plot_on_same_teams.png", width = 10, height = 6, dpi = 300, bg = "white")
