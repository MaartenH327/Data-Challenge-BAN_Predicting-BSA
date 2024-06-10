import pandas as pd
import numpy as np
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

def combine_and_encode(programs):
    # Combine all train and test dataframes
    combined_df = pd.concat([train_df for _, train_df, _ in programs] + [test_df for _, _, test_df in programs], keys=['train']*len(programs) + ['test']*len(programs))

    # Create dummies
    dummifiable_columns = ['Gender', 'Nationality', 'PreEducation', 'Program', 'Year', 'BSA']
    combined_df = pd.get_dummies(combined_df, columns=dummifiable_columns)

    # Split back into original dataframes
    train_test_splits = []
    for i, (program_name, train_df, test_df) in enumerate(programs):
        train_df_encoded = combined_df.xs('train', level=0).iloc[i*len(train_df):(i+1)*len(train_df)]
        test_df_encoded = combined_df.xs('test', level=0).iloc[i*len(test_df):(i+1)*len(test_df)]
        train_test_splits.append((program_name, train_df_encoded, test_df_encoded))

    return train_test_splits

def perform_pca_analysis(train_df, test_df, program_name):
    # Select relevant columns (up to "Crd-B1B2")
    columns_to_include = train_df.columns[:train_df.columns.get_loc("Crd-B1B2") + 1]
    train_df = train_df[columns_to_include]
    test_df = test_df[columns_to_include]

    # Separate features and target variable
    X_train = train_df.drop(columns=['Credits-Y1'])
    y_train = train_df['Credits-Y1']
    X_test = test_df.drop(columns=['Credits-Y1'])
    y_test = test_df['Credits-Y1']

    # Standardize the data
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)

    # Apply PCA
    pca = PCA()
    pca.fit(X_train_scaled)

    # Explained variance ratio
    explained_variance = pca.explained_variance_ratio_
    print(f"Explained Variance Ratio for {program_name}:")
    print(explained_variance)

    # Determine the number of components to retain (e.g., explain at least 95% variance)
    total_variance = 0
    num_components = 0
    for variance in explained_variance:
        total_variance += variance
        num_components += 1
        if total_variance >= 0.95:
            break

    print(f"\nNumber of components to retain for {program_name}: {num_components}")

    # Transform data using the selected number of components
    X_train_pca = pca.transform(X_train_scaled)[:, :num_components]
    X_test_pca = pca.transform(X_test_scaled)[:, :num_components]

    # Create DataFrames with the principal components
    pca_columns = [f'PC{i+1}' for i in range(num_components)]
    X_train_pca_df = pd.DataFrame(X_train_pca, columns=pca_columns)
    X_test_pca_df = pd.DataFrame(X_test_pca, columns=pca_columns)

    # Add the target variable 'Credits-Y1' back to the DataFrames
    X_train_pca_df['Credits-Y1'] = y_train.reset_index(drop=True)
    X_test_pca_df['Credits-Y1'] = y_test.reset_index(drop=True)

    return X_train_pca_df, X_test_pca_df

# Example usage
programs = [
    ("Program 1", program1_train_df, program1_test_df),
    ("Program 2", program2_train_df, program2_test_df),
    ("Program 3", program3_train_df, program3_test_df),
    ("Program 4", program4_train_df, program4_test_df)
]

# Combine and encode dataframes
combined_programs = combine_and_encode(programs)

pca_results = {}

for program_name, train_df, test_df in combined_programs:
    X_train_pca_df, X_test_pca_df = perform_pca_analysis(train_df, test_df, program_name)
    pca_results[program_name] = {
        'train': X_train_pca_df,
        'test': X_test_pca_df
    }

# Now you can access each program's PCA-transformed dataframes from the `pca_results` dictionary
# Example: Accessing Program 1's transformed data
program1_train_pca_df = pca_results['Program 1']['train']
program1_test_pca_df = pca_results['Program 1']['test']
