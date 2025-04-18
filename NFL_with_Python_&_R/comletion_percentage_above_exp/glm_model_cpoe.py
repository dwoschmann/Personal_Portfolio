import pandas as pd
import numpy as np
import nfl_data_py as nfl
import statsmodels.formula.api as smf
import statsmodels.api as sm
import matplotlib.pyplot as plt
import seaborn as sns
import os

season = [2024]
pbp_py = nfl.import_pbp_data(season)

# Filter the full play-by-play dataset to only include passes with valid passer and air_yards data
pbp_py_pass = pbp_py[
    (pbp_py["play_type"] == "pass") &  # Only passing plays
    (pbp_py["passer_id"].notnull()) &  # Must have a known passer
    (pbp_py["air_yards"].notnull())  # Must have air_yards data
    ].reset_index()  # Reset index after filtering

# Set up a clean visual theme for seaborn plots
sns.set_theme(style="whitegrid", palette="colorblind")

# Create a DataFrame that shows average completion rate for passes with 1-19 air yards
pass_pct_py = pbp_py_pass.query('0 < air_yards < 20') \
    .groupby('air_yards') \
    .agg({"complete_pass": ["mean"]})  # Get average completion per air_yard value

pass_pct_py.columns = ['com_pct']  # Rename column from multi-index to flat name
pass_pct_py.reset_index(inplace=True)  # Reset index so air_yards is a column

# (This line is redundant since the renaming already occurred above)
pass_pct_py.rename(columns={'complete_pass_mean': 'com_pct'}, inplace=True)

# Plot a scatter plot + regression line for air_yards vs completion percentage
sns.regplot(data=pass_pct_py, x='air_yards', y='com_pct', line_kws={'color': 'red'})
# plt.show()  # Uncomment to show the plot

# Fit a logistic regression model: does air_yards predict whether a pass is completed?
complete_ay_py = smf.glm(
    formula='complete_pass ~ air_yards',
    data=pbp_py_pass,
    family=sm.families.Binomial()
).fit()

# Add predicted completion probability from model to the dataset
pbp_py_pass["exp_completion"] = complete_ay_py.predict()

# Calculate CPOE (Completion Percentage Over Expected) = Actual - Expected
pbp_py_pass["cpoe"] = pbp_py_pass["complete_pass"] - pbp_py_pass["exp_completion"]

# Group by season and quarterback to compute CPOE and completion stats
cpoe_py = pbp_py_pass.groupby(["season", "passer_id", "passer"]).agg({
    "cpoe": ["count", "mean"],
    "complete_pass": ["mean"]
})
cpoe_py.columns = list(map('_'.join, cpoe_py.columns))  # Flatten multi-level column names
cpoe_py.reset_index(inplace=True)  # Make 'season', 'passer_id', etc. into columns

# Rename columns for clarity, and keep only QBs with more than 100 passes
cpoe_py = cpoe_py.rename(columns={
    "cpoe_count": "n",  # Number of pass attempts
    "cpoe_mean": "cpoe",  # Average CPOE
    "complete_pass_mean": "completion"  # Average completion %
}).query("n > 100")  # Only include QBs with >100 attempts

# Convert 'down' and 'qb_hit' to strings so they’re treated as categorical variables
pbp_py_pass['down'] = pbp_py_pass['down'].astype(str)
pbp_py_pass['qb_hit'] = pbp_py_pass['qb_hit'].astype(str)

# Subset and drop rows with any remaining missing data
pbp_py_pass_no_na = pbp_py_pass[[
    "passer", "passer_id", "season", "down", "qb_hit", "complete_pass",
    "ydstogo", "yardline_100", "air_yards", "pass_location"
]].dropna(axis=0)  # axis=0 means drop rows with any NaN values

# Fit a more advanced logistic regression model with more features, including interaction
complete_more_py = smf.glm(
    formula='complete_pass ~ down * ydstogo + yardline_100 + air_yards + pass_location + qb_hit',
    data=pbp_py_pass_no_na,
    family=sm.families.Binomial()
).fit()

# Predict completion probabilities with the full model
pbp_py_pass_no_na["exp_completion"] = complete_more_py.predict()
# Recalculate CPOE with the improved model
pbp_py_pass_no_na["cpoe"] = pbp_py_pass_no_na["complete_pass"] - pbp_py_pass_no_na["exp_completion"]

# Summarize the findings
cpoe_py_more = pbp_py_pass_no_na.groupby(["season", "passer_id", "passer", ]).agg({"cpoe": ["count", "mean"],
                                                                                   "complete_pass": ["mean"],
                                                                                   "exp_completion": ["mean"]})

# Flatten MultiIndex columns into single-level column names by joining them with underscores.
cpoe_py_more.columns = list(map('_'.join, cpoe_py_more.columns))
# Move the grouping columns (like season, passer_id) out of the index and back into regular columns.
cpoe_py_more.reset_index(inplace=True)
# Rename columns and sort
cpoe_py_more = cpoe_py_more.rename(columns={"cpoe_count": "n",
                                            "cpoe_mean": "cpoe",
                                            "complete_pass_mean": "compl",
                                            "exp_completion_mean": "exp_completion"}
                                   ).query("n > 100")
print(cpoe_py_more.sort_values("cpoe", ascending=False))


cpoe_py_more.to_csv("cpoe_py_more.csv", index=False)
