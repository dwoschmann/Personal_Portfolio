pbp_r <- load_pbp(2021:2024)

pbp_r_p <-
  pbp_r |>
  filter(play_type == 'pass' & !is.na(air_yards))

pbp_r_p <-
  pbp_r_p |>
  mutate(
    pass_length_air_yards = ifelse(air_yards >= 20, "long", "short"),
    passing_yards = ifelse(is.na(passing_yards), 0, passing_yards)
  )
 
pbp_r_p |>
  filter(pass_length_air_yards == "short") |>
  pull(epa) |>
  summary()

pbp_r_p |>
  filter(pass_length_air_yards == "long") |>
  pull(epa) |>
  summary()
  

ggplot(pbp_r, aes(x = passing_yards)) +
  geom_histogram()
  
pbp_r_p |>
  filter(pass_length_air_yards == "long") |>
  ggplot(aes(passing_yards)) +
  geom_histogram(binwidth = 1) +
  ylab("Count")
  xlab("Net yards on 'long' passing plays") +
  theme_bw()

ggplot(pbp_r_p, aes(x = pass_length_air_yards, y = passing_yards)) +
  geom_boxplot() +
  theme_bw() +
  xlab("Pass length in yards(long >= 20, short < 20 yards)") +
  ylab("Yards gained (or lost) during a pass play")
