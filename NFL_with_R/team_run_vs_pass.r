pbp_data <- load_pbp(2023)

team_pbp <- pbp_data %>%
  filter(!is.na(posteam) & posteam != "unknown" &
           !is.na(defteam) & defteam != "unknown")

team_summary <- team_pbp %>%
  filter(play_type %in% c("run", "pass")) %>%
  group_by(posteam) %>%
  summarise(
    run_play_count = sum(play_type == "run", na.rm = TRUE),
    pass_play_count = sum(play_type == "pass", na.rm = TRUE),
    total_plays = n(),
    run_ratio = sum(play_type == "run", na.rm = TRUE) / total_plays,
    pass_ratio = sum(play_type == "pass", na.rm = TRUE) / total_plays
  )

team_logos <- load_teams()

team_summary <- team_summary %>%
  left_join(team_logos, by = c("posteam" = "team_abbr"))

# Check if the logos are correctly merged
head(team_summary)

ggplot(team_summary, aes(x = run_ratio, y = pass_ratio)) + 
  geom_image(aes(image = team_logo_wikipedia), size = 0.05) +
  labs(
    title = "Run vs Pass Plays by Team ",
    subtitle = "2023 | Data: nflfastr | Chart: Daniel Oschmann", 
    x = "Run Ratio",
    y = "Pass Ratio"
  ) +
  scale_x_continuous(limits = c(0.3, 0.5)) +
  scale_y_continuous(limits = c(0.45, 0.7)) +
  theme_minimal()
