install.packages(c("nflreadr", "tidyverse", "gt", "gtExtras", "nflfastR", "ggimage", "ggthemes", "ggtext", "ggplot2", "ggrepel"))

library(nflreadr)
library(tidyverse)
library(gt)
library(gtExtras)
library(nflfastR)
library(ggimage)
library(ggthemes)
library(ggtext)
library(ggplot2)
library(ggrepel)


ls("package:nflfastR")

pbp <- load_pbp(2016:2023)



years <- 2016:2023
stats_list <- list()

for (year in years) {
  pbp_data <- load_pbp(year)
  defensive_stats <- calculate_player_stats_def(pbp = pbp_data)
  defensive_stats <- defensive_stats %>%
    mutate(season = year)
  stats_list[[as.character(year)]] <- defensive_stats
}

all_defensive_stats <- bind_rows(stats_list)

jalen_ramsey_stats <- all_defensive_stats %>%
  filter(player_display_name == "Jalen Ramsey")

jalen_ramsey_stats_2019 <- jalen_ramsey_stats %>%
  filter(season == 2019) %>%
  group_by(player_id, player_display_name, position, position_group, headshot_url, season) %>%
  summarize(across(c(def_tackles:def_pass_defended, games), sum, na.rm = TRUE)) %>%
  mutate(team = "LA")

jalen_ramsey_stats <- jalen_ramsey_stats %>%
  filter(season != 2019) %>%
  bind_rows(jalen_ramsey_stats_2019)

team_logos <- c(
  "JAX" = "https://upload.wikimedia.org/wikipedia/en/thumb/7/74/Jacksonville_Jaguars_logo.svg/100px-Jacksonville_Jaguars_logo.svg.png",
  "LA" = "https://upload.wikimedia.org/wikipedia/en/thumb/8/8a/Los_Angeles_Rams_logo.svg/100px-Los_Angeles_Rams_logo.svg.png",
  "MIA" = "https://upload.wikimedia.org/wikipedia/en/thumb/3/37/Miami_Dolphins_logo.svg/100px-Miami_Dolphins_logo.svg.png"
)

jalen_ramsey_stats <- jalen_ramsey_stats %>%
  mutate(team_logo = team_logos[team])

jalen_ramsey_stats_long <- jalen_ramsey_stats %>%
  pivot_longer(cols = c(def_tackles, def_interceptions, def_pass_defended, games),
               names_to = "stat",
               values_to = "value")

ggplot(jalen_ramsey_stats_long, aes(x = season, y = value, color = stat, group = stat)) +
  geom_line(size = 1) +
  geom_image(aes(image = team_logo), size = 0.05, show.legend = FALSE) +  # Use team logos as images
  scale_color_manual(values = c("def_tackles" = "blue",
                                "def_interceptions" = "green", 
                                "def_pass_defended" = "orange",
                                "games" = "red")) +  # Customize line colors
  labs(title = "Jalen Ramsey Defensive Stats by Season",
       subtitle = "Data: nflfastR | Chart: Daniel Oschmann",
       x = "Season",
       y = "Value",
       color = "Stat") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
