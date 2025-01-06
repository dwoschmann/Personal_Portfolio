player_stats <- load_player_stats(2023)
colnames(player_stats)


team_logos <- load_teams() %>%
  select(team_abbr, team_logo_wikipedia) %>%
  rename(recent_team = team_abbr)


wr_air_vs_rac <- player_stats %>%
  filter(position == "WR") %>%
  filter(!is.na(receiving_yards) & receiving_yards != 0) %>%
  drop_na(receiving_air_yards, receiving_yards_after_catch) %>%
  group_by(player_name, recent_team) %>%
  summarise(
    position = first(position),
    receiving_air_yards = sum(receiving_air_yards),
    receiving_yards_after_catch = sum(receiving_yards_after_catch),
    .groups = 'drop',
    targets = sum(targets)
  ) %>%
  filter(targets >= 50)


wr_air_vs_rac <- wr_air_vs_rac %>%
  left_join(team_logos, by = "recent_team")


ggplot(wr_air_vs_rac, aes(x = receiving_air_yards, y = receiving_yards_after_catch)) +
  geom_image(aes(image = team_logo_wikipedia), size = 0.04) +
  geom_text_repel(
    aes(label = player_name),
    size = 3,  # Smaller text size
    box.padding = 0.2,
    point.padding = 0.2,
    segment.size = 0.2,
    min.segment.length = 0,
    nudge_y = 0.1,
    nudge_x = 0.1
  ) +  
  labs(
    title = "RAC vs. Receiving Air Yards",
    subtitle = "Data: nflfastr | Chart: Daniel Oschmann",
    x = "Receiving Air Yards",
    y = "Yards After Catch"
  ) +
  theme_minimal() +
  theme(
    plot.margin = margin(10, 10, 10, 10)
  )
