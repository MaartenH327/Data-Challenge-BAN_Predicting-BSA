import pandas as pd
import statsmodels.api as sm
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error
from sklearn.ensemble import RandomForestRegressor

# Function to perform the analysis
def analyze_program(train_df, test_df, program_name):
    # Exclude the "train" column
    train_df = train_df.drop(columns=['train'])
    test_df = test_df.drop(columns=['train'])
    
    # Identify numeric columns only
    numeric_cols = train_df.select_dtypes(include=[float, int]).columns.tolist()

    # Prepare the data
    X_train = train_df[numeric_cols].drop(columns=['Credits-Y1'])
    y_train = train_df['Credits-Y1']
    X_test = test_df[numeric_cols].drop(columns=['Credits-Y1'])
    y_test = test_df['Credits-Y1']

    # Correlation Analysis
    corr_matrix = train_df[numeric_cols].corr()
    corr_with_credits = corr_matrix["Credits-Y1"].sort_values(ascending=False)
    print(f"Correlation with Credits-Y1 ({program_name} Training Data):")
    print(corr_with_credits)

    # Regression Analysis with statsmodels
    X_train_sm = sm.add_constant(X_train)
    model_sm = sm.OLS(y_train, X_train_sm).fit()
    print(f"\nRegression Analysis ({program_name} statsmodels):")
    print(model_sm.summary())

    # Regression Analysis with scikit-learn
    model_lr = LinearRegression()
    model_lr.fit(X_train, y_train)
    y_pred = model_lr.predict(X_test)
    mse = mean_squared_error(y_test, y_pred)
    coef = pd.Series(model_lr.coef_, index=X_train.columns)
    print(f'\nMean Squared Error ({program_name} scikit-learn): {mse}')
    print(f"Regression Coefficients ({program_name} scikit-learn):")
    print(coef.sort_values(ascending=False))

    # Feature Importance with Random Forest
    model_rf = RandomForestRegressor(random_state=42)
    model_rf.fit(X_train, y_train)
    importances = model_rf.feature_importances_
    feature_importances = pd.Series(importances, index=X_train.columns)
    print(f"\nFeature Importances ({program_name} Random Forest):")
    print(feature_importances.sort_values(ascending=False))

# Perform analysis for all programs
programs = [
    ("Program1", program1_train_df, program1_test_df),
    ("Program2", program2_train_df, program2_test_df),
    ("Program3", program3_train_df, program3_test_df),
    ("Program4", program4_train_df, program4_test_df)
]

for program_name, train_df, test_df in programs:
    analyze_program(train_df, test_df, program_name)
