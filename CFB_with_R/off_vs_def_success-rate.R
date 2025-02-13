library(cfbfastR)

if (!requireNamespace('pacman', quietly = TRUE)){
  install.packages('pacman')
}
pacman::p_load(tidyverse, zoo, ggimage, gt)


ls("package:cfbfastR")


team_info <- cfbd_team_info()
team_logos <- team_info[, c("school", "logo")]

cfbd_pbp_data_2024 <- cfbd_pbp_data(year = 2024)
  
team_stats_2024 <- cfbd_stats_season_team(year = 2024)
team_stats_2024 <- team_stats_2024 %>%
  left_join(team_logos, by = c("team" = "school"))

game_stats_2024 <- cfbd_stats_game_advanced(year = 2024)
game_stats_2024 <- game_stats_2024 %>%
  left_join(team_logos, by = c("team" = "school"))

colnames(cfbd_pbp_data_2024)
colnames(team_stats_2024)
colnames(game_stats_2024)


team_avg_success_table <- game_stats_2024 %>%
  group_by(team, logo) %>%
  summarise(
    avg_off_success_rate = mean(off_success_rate, na.rm = TRUE),
    avg_def_success_rate = mean(def_success_rate, na.rm = TRUE)
  ) %>%
  ungroup()


ggplot(team_avg_success_table, aes(x = avg_off_success_rate, y = avg_def_success_rate)) +
  geom_image(aes(image = logo), size = 0.06) +
  geom_hline(yintercept = mean(team_avg_success_table$avg_def_success_rate), linetype = "dashed", color = "gray") +
  geom_vline(xintercept = mean(team_avg_success_table$avg_off_success_rate), linetype = "dashed", color = "gray") +
  labs(
    title = "Average Offensive vs Defensive Success Rate (Weeks 1-2)",
    subtitle = "Through Week 1 | Data: cfbfastr | Chart: Daniel Oschmann",
    x = "Offensive Success Rate",
    y = "Defensive Success Rate"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.title = element_text(size = 12)
  )
