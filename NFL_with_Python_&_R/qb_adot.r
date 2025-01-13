pbp_r <- load_pbp(2024)

pbp_r_p <-
  pbp_r |>
  filter(play_type == 'pass' & !is.na(air_yards))

team_logos <- load_teams() |>
  select(team_abbr, team_logo_wikipedia) |>
  rename(posteam = team_abbr)

player_headshots <- load_player_stats() |>
  select(player_id, headshot_url) |>
  rename(passer_id = player_id) |>
  distinct(passer_id, .keep_all = TRUE)


adot_summary <- pbp_r_p |>
  group_by(posteam, passer_id, passer) |>
  summarize(
    n = n(),
    adot = mean(air_yards, na.rm = TRUE)
  ) |>
  filter(n >= 100 & !is.na(passer)) |>
  arrange(-adot) |>  # Sort by adot in descending order
  ungroup() |>       # Ungroup to calculate global rankings
  mutate(rank = row_number()) |>  # Add a global ranking column
  left_join(team_logos, by = "posteam") |>
  left_join(player_headshots, by = "passer_id") |>
  select(rank, team_logo_wikipedia, headshot_url, passer, n, adot)


adot_summary_table <- 
  adot_summary |>
  gt() |>
  tab_header(
    title = "NFL Quarterbacks by Average Depth of Target (aDOT)",
    subtitle = "2024 Season, Minimum 100 passing plays | Data: NFLfastR | @dumbanalytics"
  ) |>
  cols_label(
    rank = "",
    team_logo_wikipedia = "",
    headshot_url = "",
    passer = "Name",
    n = "Pass Attempts",
    adot = "Avg Depth of Target"
  ) |>
  gt_img_rows(team_logo_wikipedia, height = 20) |>
  gt_img_rows(headshot_url, height = 30) |>
  fmt_number(
    columns = c(adot),
    decimals = 2
  ) |>
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_column_labels(everything())
  ) |>
  tab_style(
    style = cell_text(align = "center"),
    locations = cells_body(columns = c(rank, n, adot))
  )

adot_summary_table
