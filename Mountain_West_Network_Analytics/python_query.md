# SDSU Viewership Data Processing (2022–2025)

This script processes SDSU's Mountain West Network live stream viewership data across three academic years (2022–23, 2023–24, and 2024–25). It reads the original Excel files, filters the data to only include San Diego State home events, adds a "Season" column to each dataset, combines them into a single DataFrame, and saves the final result to a new Excel file for analysis.


## 📊 Overview

The data originally comes from three Excel files—each covering a different academic year—and includes sheets representing various events. The script performs the following steps:

1. **Load and parse Excel sheets**
2. **Clean and filter rows to include only SDSU home games**
3. **Add a "Season" column to each year's dataset**
4. **Combine all years into a single dataset**
5. **Export the cleaned dataset for further analysis**

---

## 📁 Files Used

- `22_23_sdsu_viewership.xlsx`
- `MW Live Streaming Data (Day of Event Only) 2023-2024.xlsx`
- `MW Live Streaming Data (Day of Event Only) 2024-2025.xlsx`

---

## 🐍 Script Breakdown

### 1. Load 2022–23 Data

> **Note**:  
> The 2022–23 data was originally separated into two different files—one tracking website views and one for app views. After attempting to query both in Python, I chose to manually clean and combine those numbers in Excel due to inconsistent formatting that made automated merging too difficult.  

```python
import pandas as pd

sdsu_viewership_22_23 = pd.ExcelFile(r"C:\Users\dwosc\PycharmProjects\MWN SDSU Viewership\22_23_sdsu_viewership.xlsx")
df_22_23 = sdsu_viewership_22_23.parse(sheet_name=0)
df_22_23.to_excel("sdsu_viewership_22_23.xlsx", index=False)
```

### 2. Load 2023–24 and 2024-25 Data

> **Note**:  
> The 2023–24 and 2024–25 data were formatted consistently and combined into single Excel workbooks with separate sheets per sport, making them much easier to process and query in Python.

```python
sdsu_viewership_23_24 = pd.ExcelFile(r"C:\Job Stuff\MW Live Streaming Data (Day of Event Only) 2023-2024.xlsx")
df_23_24 = [sdsu_viewership_23_24.parse(sheet_name=sheet, header=5) for sheet in sdsu_viewership_23_24.sheet_names]
df_23_24 = pd.concat(df_23_24, ignore_index=True)
df_23_24 = df_23_24[df_23_24['Home Team'] == 'San Diego State']
df_23_24.to_excel("sdsu_viewership_23_24.xlsx", index=False)

sdsu_viewership_24_25 = pd.ExcelFile(r"C:\Job Stuff\MW Live Streaming Data (Day of Event Only) 2024-2025.xlsx")
df_24_25 = [sdsu_viewership_24_25.parse(sheet_name=sheet, header=5) for sheet in sdsu_viewership_23_24.sheet_names]
df_24_25 = pd.concat(df_24_25, ignore_index=True)
df_24_25 = df_24_25[df_24_25['Home Team'].str.contains('SDSU|San Diego State', na=False, case=False)]
df_24_25.to_excel("sdsu_viewership_24_25.xlsx", index=False)
```

### 3. Add Season Labels and Combine All Years

```python
df_22_23 = pd.read_excel("sdsu_viewership_22_23.xlsx")
df_23_24 = pd.read_excel("sdsu_viewership_23_24.xlsx")
df_24_25 = pd.read_excel("sdsu_viewership_24_25.xlsx")

df_22_23['Season'] = '2022–23'
df_23_24['Season'] = '2023–24'
df_24_25['Season'] = '2024–25'

combined_df = pd.concat([df_22_23, df_23_24, df_24_25], ignore_index=True)
combined_df.to_excel("sdsu_combined_viewership_22_to_25.xlsx", index=False)
```

### 4. Load and Verify Final Cleaned Output

> **Note**:  
> After automated processing, the combined data was manually cleaned and resaved into the final version.

```python
cleaned_sdsu_combined_viewership_22_to_25 = pd.read_excel(r"C:\Users\dwosc\PycharmProjects\MWN SDSU Viewership\cleaned_sdsu_combined_viewership_22_to_25.xlsx")
print(cleaned_sdsu_combined_viewership_22_to_25)
```
