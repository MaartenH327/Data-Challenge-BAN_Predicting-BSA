from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

def program_analysis_with_pca(train_df, test_df, program_name):
    # Combine dfs
    combined_df = pd.concat([train_df, test_df], keys=['train', 'test'])

    # Get dummies and add personal extra variables
    b1_index = [8,9,12,13]
    b2_index = [10,11]
    combined_df['Crd-B1'] = combined_df.iloc[:, b1_index].sum(axis=1)
    combined_df['Crd-B2'] = combined_df.iloc[:, b2_index].sum(axis=1)
    dummifiable_columns = ['Gender', 'Nationality', 'PreEducation','Year']
    dummies = pd.get_dummies(combined_df[dummifiable_columns], dtype=int)
    combined_df = combined_df.drop(columns=dummifiable_columns)
    combined_df = pd.concat([combined_df, dummies], axis = 1)

    # Split back into original dfs
    train_df = combined_df.xs('train')
    test_df = combined_df.xs('test')

    # Exclude the unnecessary columns
    train_df = train_df.drop(columns=['train', 'Program'])
    test_df = test_df.drop(columns=['train', 'Program'])
    
    # Identify numeric columns only
    numeric_cols = train_df.select_dtypes(include=[float, int]).columns.tolist()
    numeric_cols_2 = test_df.select_dtypes(include=[float, int]).columns.tolist()

    # Prepare the data
    X_train = train_df[numeric_cols].drop(columns=['Credits-Y1'])
    y_train = train_df['Credits-Y1']
    X_test = test_df[numeric_cols_2].drop(columns=['Credits-Y1'])
    y_test = test_df['Credits-Y1']

    X_train = X_train.replace([np.inf, -np.inf], np.nan).fillna(0)
    X_test = X_test.replace([np.inf, -np.inf], np.nan).fillna(0)

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

    # Select relevant features based on correlation and regression analysis
    relevant_features = [
        'Crd-B1B2', 'Crd-B1', 'Crd-B2',
        'Course8', 'Course22', 'Course25', 'Course23', 'Course9', 'Course26',  # Program 1
        'Course2', 'Course28', 'Course13', 'Course1', 'Course14', 'Course10', 'Course27', 'Course29',  # Program 2 & 3
        'Course5', 'Course18', 'Course19', 'Course20', 'Course17'  # Program 4
    ]
    relevant_features = [feature for feature in relevant_features if feature in X_train.columns]

    # Standardize the data
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train[relevant_features])
    X_test_scaled = scaler.transform(X_test[relevant_features])

    # Apply PCA
    pca = PCA()
    X_train_pca = pca.fit_transform(X_train_scaled)
    X_test_pca = pca.transform(X_test_scaled)

    # Explained variance ratio
    explained_variance = pca.explained_variance_ratio_
    print(f"\nExplained Variance Ratio ({program_name} PCA):")
    print(explained_variance)

    # Determine number of components to keep (e.g., explain at least 95% variance)
    total_variance = 0
    num_components = 0
    for variance in explained_variance:
        total_variance += variance
        num_components += 1
        if total_variance >= 0.95:
            break
    print(f"\nNumber of components to retain for {program_name}: {num_components}")

    # Create a new dataframe with the principal components
    X_train_pca_df = pd.DataFrame(X_train_pca[:, :num_components], columns=[f'PC{i+1}' for i in range(num_components)])
    X_test_pca_df = pd.DataFrame(X_test_pca[:, :num_components], columns=[f'PC{i+1}' for i in range(num_components)])

    return X_train_pca_df, y_train, X_test_pca_df, y_test
