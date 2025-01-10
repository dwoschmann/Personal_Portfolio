import pandas as pd
import numpy as np
import nfl_data_py as nfl
import seaborn as sns
import matplotlib.pyplot as plt
import os

pbp_py = nfl.import_pbp_data([2024])

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

sns.displot(data=pbp_py, x="passing_yards")
plt.show()

sns.set_theme(style="whitegrid", palette="colorblind")

pbp_py_p_short = pbp_py_p.query('pass_length_air_yards == "short"')

pbp_py_hist_short = sns.displot(data=pbp_py_p_short, binwidth=1, x="passing_yards")
pbp_py_hist_short.set_axis_labels(
    "Yards gained (or lost) during a passing play", "Count"
)
plt.show()

pass_boxplot = sns.boxplot(data=pbp_py_p, x="pass_length_air_yards", y="passing_yards")
pass_boxplot.set(
    xlabel="Pass length (long >= 20 yards, short < 20 yards)",
    ylabel="Yards gained (or lost) during a passing play",
)
plt.show()
