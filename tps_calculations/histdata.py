import pandas as pd
import matplotlib.pyplot as plt

# Assuming 'pricexrp', 'pricehbar', and 'databnb' are your DataFrames
# Replace the file paths and column names as needed
pricexrp = pd.read_csv('tps_calculations/pricexrp.csv')
pricehbar = pd.read_csv('tps_calculations/pricehbar.csv')
databnb = pd.read_csv('tps_calculations/pricebnb.csv')

# Convert 'Vol.' columns to numeric format if needed
for df in [pricexrp, pricehbar, databnb]:
    if 'Vol.' in df:
        df['Vol.'] = df['Vol.'].apply(lambda x: float(x[:-1]) * (1e6 if x[-1] == 'M' else 1e9) if isinstance(x, str) else x)

# Filter data for the time period from January 1, 2022, to present
start_date = '2022-01-01'
end_date = pd.to_datetime('today')

# Replace 'date' with the actual date column names
date_column_xrp = 'Date'  # Change this to the actual column name for the date in df_xrp
date_column_hbar = 'Date'  # Change this to the actual column name for the date in df_hbar
date_column_bnb = 'Start'  # Change this to the actual column name for the date in df_bnb

# XRP
pricexrp[date_column_xrp] = pd.to_datetime(pricexrp[date_column_xrp], format='%d/%m/%Y')
df_xrp = pricexrp[(pricexrp[date_column_xrp] >= start_date) & (pricexrp[date_column_xrp] <= end_date)]
pricexrp[date_column_xrp] = pd.to_datetime(pricexrp[date_column_xrp], format='%Y-%m-%d')  # Reset the 'Date' column format for plotting

# HBAR
pricehbar[date_column_hbar] = pd.to_datetime(pricehbar[date_column_hbar], format='%d/%m/%Y')
df_hbar = pricehbar[(pricehbar[date_column_hbar] >= start_date) & (pricehbar[date_column_hbar] <= end_date)]
pricehbar[date_column_hbar] = pd.to_datetime(pricehbar[date_column_hbar], format='%Y-%m-%d')  # Reset the 'Date' column format for plotting

# BNB
databnb[date_column_bnb] = pd.to_datetime(databnb[date_column_bnb], format='%Y-%m-%d')  # Adjust the format if needed
df_bnb = databnb[(databnb[date_column_bnb] >= start_date) & (databnb[date_column_bnb] <= end_date)]
databnb[date_column_bnb] = pd.to_datetime(databnb[date_column_bnb], format='%Y-%m-%d')  # Reset the 'Date' column format for plotting

# Plotting bar graphs for historical transaction volumes from January 1, 2022, to present
fig, axes = plt.subplots(3, 1, figsize=(12, 15))

# XRP
axes[0].bar(pricexrp[date_column_xrp], pricexrp['Vol.'], width=0.8, label='XRP', alpha=0.7)
axes[0].set_ylabel('Transaction Volume')
axes[0].set_title('XRP - Historical Transaction Volumes (Jan 1, 2022 - Present)')

# HBAR
axes[1].bar(pricehbar[date_column_hbar], pricehbar['Vol.'], width=0.8, label='HBAR', alpha=0.7)
axes[1].set_ylabel('Transaction Volume')
axes[1].set_title('HBAR - Historical Transaction Volumes (Jan 1, 2022 - Present)')

# BNB
axes[2].bar(databnb[date_column_bnb], databnb['Volume'], width=0.8, label='BNB', alpha=0.7)
axes[2].set_xlabel('Date')
axes[2].set_ylabel('Transaction Volume')
axes[2].set_title('BNB - Historical Transaction Volumes (Jan 1, 2022 - Present)')

plt.tight_layout()
plt.show()
