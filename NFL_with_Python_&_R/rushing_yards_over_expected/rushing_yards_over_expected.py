import pandas as pd
import numpy as np
import nfl_data_py as nfl
import statsmodels.formula.api as smf
import matplotlib.pyplot as plt
import seaborn as sns

seasons = range(2021, 2024 + 1)
pbp_py = nfl.import_pbp_data(seasons)

pbp_py_run = pbp_py.query('play_type == "run" & rusher_id.notnull()')
pbp_py_run.reset_index()
pbp_py_run.loc[pbp_py_run.rushing_yards.isnull(), "rushing_yards"] = 0

sns.set_theme(style="whitegrid", palette='colorblind')
sns.scatterplot(data=pbp_py_run, x="ydstogo", y="rushing_yards")
plt.show()

sns.regplot(data=pbp_py_run, x="ydstogo", y="rushing_yards")
plt.show()

pbp_py_run_ave = pbp_py_run.groupby(["ydstogo"]).agg({"rushing_yards": ["mean"]})
pbp_py_run_ave.columns = list(map("_".join, pbp_py_run_ave.columns))
pbp_py_run_ave.reset_index(inplace=True)

sns.regplot(data=pbp_py_run_ave, x="ydstogo", y="rushing_yards_mean")
plt.show()


yard_to_go_py = smf.ols(formula="rushing_yards ~ 1 + ydstogo", data=pbp_py_run)

pbp_py_run["ryoe"] = yard_to_go_py.fit().resid

ryoe_py = pbp_py_run \
    .groupby(["season", "rusher_id", "rusher"]) \
    .agg({
    "ryoe": ["count", "sum", "mean"],
    "rushing_yards": "mean"})

# flatten column names
ryoe_py.columns = list(map("_".join, ryoe_py.columns))
# reset the index to make grouped fields columns
ryoe_py.reset_index(inplace=True)

ryoe_py = ryoe_py.rename(
    columns={
        "ryoe_count": "n",
        "ryoe_sum": "ryoe_total",
        "ryoe_mean": "ryoe_per",
        "rushing_yards_mean": "yards_per_carry",
    }
)


# keep only needed columns
cols_keep = ["season", "rusher_id", "rusher", "ryoe_per", "yards_per_carry"]

# create current dataframe
ryoe_now_py = ryoe_py[cols_keep].copy()

# create last years dataframe
ryoe_last_py = ryoe_py[cols_keep].copy()

# rename columns
ryoe_last_py.rename(columns=
                    {'ryoe_per': 'ryoe_per_last',
                     'yards_per_carry': 'yards_per_carry_last'},
                    inplace=True
                    )

# add 1 to season
ryoe_last_py["season"] += 1

# merge last season's data with the current season's data
ryoe_lag_py = ryoe_now_py.merge(ryoe_last_py, how="inner", on=["rusher_id", "rusher", "season"])

print(ryoe_lag_py[["yards_per_carry_last", "yards_per_carry"]].corr())
print(ryoe_lag_py[["ryoe_per_last", "ryoe_per"]].corr())
