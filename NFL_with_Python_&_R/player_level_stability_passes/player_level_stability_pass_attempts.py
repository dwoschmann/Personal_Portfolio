import numpy as np
import nfl_data_py as nfl

pbp_py = nfl.import_pbp_data(range(2021, 2024 + 1))

pbp_py_p = pbp_py.query("play_type == 'pass' & air_yards.notnull()").reset_index()

pbp_py_p["pass_length_air_yards"] = np.where(
    pbp_py_p["air_yards"] >= 20, "long", "short"
)

pbp_py_p["passing_yards"] = np.where(
    pbp_py_p["passing_yards"].isnull(), 0, pbp_py_p["passing_yards"]
)

pbp_py_p["passing_yards"].describe()

pbp_py_p.query('pass_length_air_yards == "short"')["passing_yards"].describe()
pbp_py_p.query('pass_length_air_yards == "long"')["passing_yards"].describe()
pbp_py_p.query('pass_length_air_yards == "short"')["epa"].describe()
pbp_py_p.query('pass_length_air_yards == "long"')["epa"].describe()


pbp_py_p_s = pbp_py_p.groupby(["passer_id", "passer", "season"]).agg(
    {"passing_yards": ["mean", "count"]}
)

pbp_py_p_s.columns = list(map("_".join, pbp_py_p_s.columns.values))

pbp_py_p_s.rename(
    columns={"passing_yards_mean": "ypa", "passing_yards_count": "n"}, inplace=True
)
pbp_py_p_s_100 = pbp_py_p_s.query("n >= 100").sort_values(by=["ypa"], ascending=False)


pbp_py_p_s_pl = pbp_py_p.groupby(
    ["passer_id", "passer", "season", "pass_length_air_yards"]
).agg({"passing_yards": ["mean", "count"]})

pbp_py_p_s_pl.columns = list(map("_".join, pbp_py_p_s_pl.columns.values))
pbp_py_p_s_pl.rename(
    columns={"passing_yards_mean": "ypa", "passing_yards_count": "n"}, inplace=True
)

pbp_py_p_s_pl.reset_index(inplace=True)

q_value = (
    "(n >= 100 & "
    + 'pass_length_air_yards == "short") | '
    + "(n >= 30 & "
    + 'pass_length_air_yards == "long")'
)
pbp_py_p_s_pl = pbp_py_p_s_pl.query(q_value).reset_index()

cols_save = ["passer_id", "passer", "season", "pass_length_air_yards", "ypa"]
air_yards_py = pbp_py_p_s_pl[cols_save].copy()

air_yards_lag_py = air_yards_py.copy()
air_yards_lag_py["season"] += 1
air_yards_lag_py.rename(columns={"ypa": "ypa_last"}, inplace=True)

pbp_py_p_s_pl = air_yards_py.merge(
    air_yards_lag_py,
    how="inner",
    on=["passer_id", "passer", "season", "pass_length_air_yards"],
)
pbp_py_p_s_pl.sort_values(["passer", "pass_length_air_yards", "season"])

print(pbp_py_p_s_pl)
