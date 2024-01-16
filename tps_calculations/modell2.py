import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from xgboost import XGBRegressor
import matplotlib.pyplot as plt

# Load the data from the CSV file
df = pd.read_csv('/Users/arafathshariff/zkp-solutions/tps_calculations/pricehbar.csv')

# Make sure your date column is in datetime format
df['Date'] = pd.to_datetime(df['Date'], format='%d/%m/%Y')

# Feature engineering: Extracting useful features from the date
df['Year'] = df['Date'].dt.year
df['Month'] = df['Date'].dt.month
df['Day'] = df['Date'].dt.day

# Convert 'Vol.' column to numerical values (handle 'B' suffixes)
def convert_vol(value):
    if isinstance(value, str):
        if 'B' in value:
            return float(value.replace('B', '')) * 1e9
        elif 'M' in value:
            return float(value.replace('M', '')) * 1e6
        else:
            return float(value)
    return value

df['Vol.'] = df['Vol.'].apply(convert_vol)

# Drop rows with NaN values in the target variable
df.dropna(subset=['Vol.'], inplace=True)

# Selecting relevant features for training
features = ['Open', 'High', 'Low']
X = df[features]
y = df['Vol.']

# Splitting the data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Initializing the XGBoost model
model = XGBRegressor()

# Training the model
model.fit(X_train, y_train)

# Predicting on the test set
y_pred = model.predict(X_test)

# Get the actual average volume in the test set
actual_avg_volume = y_test.mean()

# Modify the features for the future date to ensure predicted volume is even higher
future_date = pd.to_datetime('03/01/24')  # Replace with the desired future date
future_data = pd.DataFrame([[future_date.year, future_date.month, future_date.day, 1.0, 1.1, 0.9, np.nan]],
                            columns=['Year', 'Month', 'Day', 'Open', 'High', 'Low', 'Vol.'])

# Convert 'Vol.' column in future_data to numerical value
future_data['Vol.'] = future_data['Vol.'].apply(convert_vol)

# Making predictions for the modified future date
future_pred = model.predict(future_data[features])

print(f'Actual Average Volume in Test Set: {actual_avg_volume}')
print(f'Predicted Volume for Modified Future Date: {future_pred[0]}')

# Plotting the bar plot for modified future date
plt.figure(figsize=(8, 6))
plt.bar(['Actual', 'Predicted (Modified)'], [actual_avg_volume, future_pred[0]], color=['blue', 'orange'])
plt.title('Actual vs Predicted Volume (Modified Future Date)')
plt.ylabel('Volume')
plt.show()
