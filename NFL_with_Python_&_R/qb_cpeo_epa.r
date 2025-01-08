player_stats <- load_player_stats(2024)

team_logos <- load_teams() %>%
  select(team_abbr, team_logo_wikipedia) %>%
  rename(recent_team = team_abbr)

pbp <- load_pbp(2024)

colnames(player_stats)
colnames(pbp)

print(pbp["cpoe"])

View(pbp)


snaps_per_player <- pbp %>%
  group_by(passer_player_name) %>%
  summarise(total_snaps = n())

players_with_min_snaps <- snaps_per_player %>%
  filter(total_snaps >= 20)

average_cpoe_by_player <- pbp %>%
  drop_na(passer_player_name, cpoe) %>%
  group_by(passer_player_name) %>%
  summarise(average_cpoe = mean(cpoe, na.rm = TRUE)) %>%
  inner_join(players_with_min_snaps, by = "passer_player_name")

qb_cpoe_qb_epa <- pbp %>%
  group_by(passer_player_name, posteam) %>%
  summarise(
    cpoe = mean(cpoe, na.rm = TRUE),
    qb_epa = mean(qb_epa, na.rm = TRUE)
  ) %>%
  inner_join(player_stats, by = c("passer_player_name" = "player_name")) %>%
  filter(position == "QB") %>%
  group_by(passer_player_name, recent_team) %>%
  summarise(
    position = first(position),
    cpoe = mean(cpoe, na.rm = TRUE),
    qb_epa = mean(qb_epa, na.rm = TRUE)
  ) %>%
  left_join(average_cpoe_by_player, by = "passer_player_name") %>%
  left_join(team_logos, by = "recent_team")

qb_cpoe_qb_epa <- qb_cpoe_qb_epa %>%
  drop_na()


view(qb_cpoe_qb_epa)


ggplot(qb_cpoe_qb_epa, aes(x = cpoe, y = qb_epa)) +
  geom_image(aes(image = team_logo_wikipedia), size = 0.04) +
  geom_text_repel(
    aes(label = passer_player_name),
    size = 3,
    box.padding = 0.2,
    point.padding = 0.2,
    segment.color = NA,  # Hides the connecting lines
    nudge_y = 0,
    nudge_x = 0,
    max.overlaps = Inf
  ) +  
  labs(
    title = "QB EPA and CPOE",
    subtitle = "Through Week 1 | Min 20 Snaps | Data: nflfastr | Chart: Daniel Oschmann",
    x = "Completion % Above Expected (CPOE)",
    y = "EPA Per Play (Passes)"
  ) +
  theme_minimal() +
  theme(
    plot.margin = margin(10, 10, 10, 10)
  )
