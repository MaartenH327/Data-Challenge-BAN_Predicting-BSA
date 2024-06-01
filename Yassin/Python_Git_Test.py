import pandas as pd
import statsmodels.api as sm
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error
from sklearn.ensemble import RandomForestRegressor

# Load your DataFrame
df = pd.read_excel("path_to_your_file.xlsx", sheet_name="your_sheet_name")

# Correlation Analysis
corr_matrix = df.corr()
corr_with_credits = corr_matrix["Credits-Y1"].sort_values(ascending=False)
print("Correlation with Credits-Y1:")
print(corr_with_credits)

# Regression Analysis with statsmodels
X = df.drop(columns=['Credits-Y1'])
y = df['Credits-Y1']
X = sm.add_constant(X)
model = sm.OLS(y, X).fit()
print("\nRegression Analysis (statsmodels):")
print(model.summary())

# Regression Analysis with scikit-learn
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
model = LinearRegression()
model.fit(X_train, y_train)
y_pred = model.predict(X_test)
mse = mean_squared_error(y_test, y_pred)
coef = pd.Series(model.coef_, index=X.columns)
print(f'\nMean Squared Error: {mse}')
print("Regression Coefficients (scikit-learn):")
print(coef.sort_values(ascending=False))

# Feature Importance with Random Forest
model = RandomForestRegressor(random_state=42)
model.fit(X_train, y_train)
importances = model.feature_importances_
feature_importances = pd.Series(importances, index=X.columns)
print("\nFeature Importances (Random Forest):")
print(feature_importances.sort_values(ascending=False))
