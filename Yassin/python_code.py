import pandas as pd # type: ignore
import statsmodels.api as sm
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error
from sklearn.ensemble import RandomForestRegressor

def get_df(file_path, sheet_name):
    return pd.read_excel(file_path, sheet_name)

program1_train_df = get_df("BSA-DataSet_2122_2223-TrainingData.xlsx", "Program1")
program2_train_df = get_df("BSA-DataSet_2122_2223-TrainingData.xlsx", "Program2")
program3_train_df = get_df("BSA-DataSet_2122_2223-TrainingData.xlsx", "Program3")
program4_train_df = get_df("BSA-DataSet_2122_2223-TrainingData.xlsx", "Program4")

program1_test_df = get_df("BSA-DataSet_2122_2223-TestData.xlsx", "Program1")
program2_test_df = get_df("BSA-DataSet_2122_2223-TestData.xlsx", "Program2")
program3_test_df = get_df("BSA-DataSet_2122_2223-TestData.xlsx", "Program3")
program4_test_df = get_df("BSA-DataSet_2122_2223-TestData.xlsx", "Program4")

print(program1_train_df.columns)

# Function to perform the analysis
def program_analysis(train_df, test_df, program_name):
    # Create dummies
    train_df = pd.get_dummies(train_df, columns=['Gender', 'Nationality', 'PreEducation','Year'], dtype=int)
    test_df = pd.get_dummies(test_df, columns=['Gender', 'Nationality', 'PreEducation','Year'], dtype=int)

    # Exclude the unnecessary columns
    train_df = train_df.drop(columns=['train'])
    test_df = test_df.drop(columns=['train'])
    
    # Identify numeric columns only
    numeric_cols = train_df.select_dtypes(include=[float, int, str]).columns.tolist()

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

programs = [
    ("Program 1", program1_train_df, program1_test_df),
    ("Program 2", program2_train_df, program2_test_df),
    ("Program 3", program3_train_df, program3_test_df),
    ("Program 4", program4_train_df, program4_test_df)
]

for program_name, train_df, test_df in programs:
    program_analysis(train_df, test_df, program_name)