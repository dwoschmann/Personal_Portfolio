pbp_r <- load_pbp(2021:2024)

pbp_r_run <-
  pbp_r |>
  # Filter for rows where the play type is "run" and the rusher_id is not missing
  filter(play_type == "run" & !is.na(rusher_id)) |>
  # Replace missing values in the rushing_yards column with 0
  mutate(rushing_yards = ifelse(is.na(rushing_yards), 0, rushing_yards))

ggplot(pbp_r_run, aes(x = ydstogo, y = rushing_yards)) +
  geom_point() +
  stat_smooth(method = "lm", se = TRUE) +
  theme_bw()

pbp_r_run_ave <-
  pbp_r_run |>
  group_by(ydstogo) |>
  summarize(ypc = mean(rushing_yards))

ggplot(pbp_r_run_ave, aes(x = ydstogo, y = ypc)) +
  geom_point() +
  stat_smooth(method = "lm", se = TRUE) +
  theme_bw()


yard_to_go_r <-
  lm(rushing_yards ~ 1 + ydstogo, data = pbp_r_run)

pbp_r_run <-
  pbp_r_run |>
  mutate(ryoe = resid(yard_to_go_r))


ryoe_r <-
  pbp_r_run |>
  group_by(season, rusher_id, rusher) |>
  summarize(
    n = n(),
    ryoe_total = sum(ryoe),
    ryoe_per = mean(ryoe),
    yards_per_carry = mean(rushing_yards)
  ) |>
  arrange(-ryoe_total)


ryoe_now_r <-
  ryoe_r |>
  select(-n, -ryoe_total)

ryoe_last_r <-
  ryoe_r |>
  select(-n, -ryoe_total) |>
  mutate(season = season + 1) |>
  rename(ryoe_per_last = ryoe_per,
         yards_per_carry_last = yards_per_carry)


ryoe_lag_r <-
  ryoe_now_r |>
  inner_join(ryoe_last_r,
             by = c("rusher_id", "rusher", "season")
             ) |>
  ungroup()

ryoe_lag_r |>
  select(yards_per_carry, yards_per_carry_last) |>
  cor(use = "complete.obs")

# Filter Players who Changed Teams or Stayed with the Same Team
ryoe_lag_r <- ryoe_lag_r |>
  mutate(changed_team = posteam != posteam_last)

# Load Player Headshots
player_headshots <- load_player_stats(seasons = 2023:2024) |>
  select(player_id, headshot_url) |>
  rename(rusher_id = player_id) |>
  distinct(rusher_id, .keep_all = TRUE)

# Merge Headshots with Data
ryoe_lag_r <- 
  ryoe_lag_r |>
  inner_join(player_headshots, by = "rusher_id")


ryoe_plot_on_new_teams <-
  ggplot(ryoe_lag_r |> filter(changed_team == TRUE), aes(x = ryoe_per_last, y = ryoe_per)) +
  geom_image(aes(image = headshot_url), size = 0.1) +
  scale_y_continuous(limits = c(-2, 2)) +
  scale_x_continuous(limits = c(-2, 3.5)) +
  labs(title = "RYOE Per Attempt: 2023 vs. 2024 | Players who switched teams in 2024",
       subtitle = "Minimum 50 carries both seasons | Data: nflfastR | Chart: @dumbanalytics",
       x = "RYOE Per Attempt 2023",
       y = "RYOE Per Attempt 2024") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black") +
  theme_minimal()

ggsave("ryoe_plot_on_new_teams.png", width = 10, height = 6, dpi = 300, bg = "white")

ryoe_plot_on_same_teams <-
  ggplot(ryoe_lag_r |> filter(changed_team == FALSE), aes(x = ryoe_per_last, y = ryoe_per)) +
  geom_image(aes(image = headshot_url), size = 0.1) +
  scale_y_continuous(limits = c(-2, 2)) +
  scale_x_continuous(limits = c(-2, 3.5)) +
  labs(title = "RYOE Per Attempt: 2023 vs. 2024 | Players who stayed with team in 2024",
       subtitle = "Minimum 50 carries both seasons | Data: nflfastR | Chart: @dumbanalytics",
       x = "RYOE Per Attempt 2023",
       y = "RYOE Per Attempt 2024") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black") +
  theme_minimal()

ggsave("ryoe_plot_on_same_teams.png", width = 10, height = 6, dpi = 300, bg = "white")
