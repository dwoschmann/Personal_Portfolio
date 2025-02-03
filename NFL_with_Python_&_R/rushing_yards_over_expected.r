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

ryoe_lag_r
