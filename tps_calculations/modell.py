import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from xgboost import XGBRegressor
import matplotlib.pyplot as plt

# Load the data from the CSV file
df = pd.read_csv('/Users/arafathshariff/zkp-solutions/tps_calculations/pricebnb.csv')

# Make sure your date columns are in datetime format
df['Start'] = pd.to_datetime(df['Start'])

# Feature engineering: Extracting useful features from the date
df['Year'] = df['Start'].dt.year
df['Month'] = df['Start'].dt.month
df['Day'] = df['Start'].dt.day

# Selecting relevant features for training
features = ['Year', 'Month', 'Day', 'Open', 'High', 'Low', 'Close', 'Volume', 'Market Cap']
X = df[features]
y = df['Volume']

# Splitting the data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Initializing the XGBoost model
model = XGBRegressor()

# Training the model
model.fit(X_train, y_train)

# Predicting on the test set
y_pred = model.predict(X_test)

# Predicting the volume for a future date
future_date = pd.to_datetime('03/01/24')  # Replace with the desired future date
future_data = pd.DataFrame([[future_date.year, future_date.month, future_date.day, 312.8798, 315.579, 307.761, 314.229, np.nan, np.nan]],
                            columns=['Year', 'Month', 'Day', 'Open', 'High', 'Low', 'Close', 'Volume', 'Market Cap'])

# Making predictions for the future date
future_pred = model.predict(future_data[features])

print(f'Predicted Volume for {future_date}: {future_pred[0]}')

# Plotting the bar plot for predicted volume values
plt.figure(figsize=(8, 6))
plt.bar(['Actual', 'Predicted'], [y_test.mean(), future_pred[0]], color=['blue', 'orange'])
plt.title('Actual vs Predicted Volume')
plt.ylabel('Volume')
plt.show()
