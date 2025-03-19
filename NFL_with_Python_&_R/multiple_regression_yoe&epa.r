library(tidyverse)
library(nflfastR)
library(broom)
library(dplyr)


pbp_r <- load_pbp(2024)

pbp_r_run <- pbp_r |>
  filter(play_type == "run" &
           !is.na(rusher_id) &
           !is.na(down) &
           !is.na(run_location)) |>
  mutate(rushing_yards = ifelse(is.na(rushing_yards), 0, rushing_yards))

# Change down to be an integer
pbp_r_run <-
  pbp_r_run |>
  mutate(down = as.character(down))


## Multiple logistic regression
pbp_r_run <-
  pbp_r_run |>
  mutate(down = as.character(down))

expected_yards_rushing_r <-
  lm(
    rushing_yards ~ 1 + down + ydstogo +
      down:ydstogo + yardline_100 + run_location + score_differential,
    data = pbp_r_run
  )

pbp_r_run <-
  pbp_r_run |>
  mutate(ryoe = resid(expected_yards_rushing_r))

print(summary(expected_yards_rushing_r))


## Analyze RYOE
ryoe_r <-
  pbp_r_run |>
  group_by(season, posteam) |>
  summarize(
    carries = n(), ryoe_total = sum(ryoe),
    ryoe_per = mean(ryoe), yards_per_carry = mean(rushing_yards)
  ) |>
  filter(carries > 50)


## Rushing EPA
repa_r <-
  pbp_r_run |>
  filter(play_type == "run") |>
  group_by(season, posteam) |>
  summarize(
    carries = n(), epa_total = sum(epa),
    epa_per = mean(epa), yards_per_carry = mean(rushing_yards)
  ) |>
  filter(carries > 50)

ryoe_repa_rushing_r  <-
  repa_r |>
  inner_join(ryoe_r, by = c("posteam", "season", "carries", "yards_per_carry")) |>
  ungroup()



pbp_r_passing <- pbp_r |>
  filter(play_type == "pass" &
           !is.na(passer_id) &
           !is.na(down) &
           !is.na(pass_location)) |>
  mutate(passing_yards = ifelse(is.na(passing_yards), 0, passing_yards))

# Change down to be an integer
pbp_r_passing <-
  pbp_r_passing |>
  mutate(down = as.character(down))


## Multiple logistic regression
pbp_r_passing <-
  pbp_r_passing |>
  mutate(down = as.character(down))

expected_yards_passing_r <-
  lm(
    passing_yards ~ 1 + down + ydstogo +
      down:ydstogo + yardline_100 + pass_location + score_differential,
    data = pbp_r_passing
  )

pbp_r_passing <-
  pbp_r_passing |>
  mutate(pyoe = resid(expected_yards_passing_r))

print(summary(expected_yards_passing_r))


## Analyze PYOE
pyoe_r <-
  pbp_r_passing |>
  group_by(season, posteam) |>
  summarize(
    pass_attempts = n(), pyoe_total = sum(pyoe),
    pyoe_per = mean(pyoe), yards_per_pass = mean(passing_yards)
  ) |>
  filter(pass_attempts > 100)


## Passing EPA
pepa_r <-
  pbp_r_passing |>
  filter(play_type == "pass") |>
  group_by(season, posteam) |>
  summarize(
    pass_attempts = n(), pyoe_total = sum(pyoe),
    pyoe_per = mean(pyoe), yards_per_pass = mean(passing_yards)
  ) |>
  filter(pass_attempts > 100)

pyoe_pepa_passing_r  <-
  pepa_r |>
  inner_join(pyoe_r, by = c("posteam", "season", "pass_attempts", "yards_per_pass", "pyoe_total", "pyoe_per")) |>
  ungroup()


# Summarize Rushing Efficiency
rushing_summary <- pbp_r_run |>
  summarize(
    avg_yards_per_rush = mean(rushing_yards, na.rm = TRUE),
    avg_epa_per_rush = mean(epa, na.rm = TRUE),
    yards_sd = sd(rushing_yards, na.rm = TRUE),
    epa_sd = sd(epa, na.rm = TRUE)
  )

# Summarize Passing Efficiency
passing_summary <- pbp_r_passing |>
  summarize(
    avg_yards_per_pass = mean(passing_yards, na.rm = TRUE),
    avg_epa_per_pass = mean(epa, na.rm = TRUE),
    yards_sd = sd(passing_yards, na.rm = TRUE),
    epa_sd = sd(epa, na.rm = TRUE)
  )

rushing_summary
passing_summary


## Combine EPA, RYOE, PYOE for each team
team_epa_pyoe_ryoe <-
  ryoe_repa_rushing_r |>
  inner_join(pyoe_pepa_passing_r, by = c("posteam", "season"))
