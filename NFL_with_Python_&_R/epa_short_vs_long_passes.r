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
 
  
pbp_r_p_epa_hist <-   
  pbp_r_p |>
    filter(pass_length_air_yards == "long") |>
    ggplot(aes(epa)) +
    geom_histogram(binwidth = 1) +
    ylab("Number of Plays") +
    xlab("EPA per play") +
    theme_bw()

pbp_r_p_epa_boxplot <-  
  ggplot(pbp_r_p, aes(x = pass_length_air_yards, y = epa)) +
    geom_boxplot() +
    theme_bw() +
    xlab("Pass length in yards(long >= 20, short < 20 yards)") +
    ylab("EPA per play")

pbp_r_p_epa_hist
pbp_r_p_epa_boxplot
