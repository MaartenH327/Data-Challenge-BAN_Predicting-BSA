import numpy as np
import pandas as pd
from sklearn.svm import SVC
from sklearn.impute import SimpleImputer
import TrainModel

def PrepareDF(df):
    columns_to_drop = [col for col in df.columns if (col.startswith(("3","4","5","6")) and col.endswith("EndGrade") == False)]
    
    columns_to_drop += [col for col in df.columns if (col.startswith(("2")) and col.endswith("Endgrade"))]
    columns_to_drop += [col for col in df.columns if (col.endswith("_standardized") )]   
    #columns_to_drop += [col for col in df.columns if ("grade" in col.lower() )]
    columns_to_drop += [col for col in df.columns if "_FirstTryPassed" in col]  
    columns_to_drop += [col for col in df.columns if "_FirstTryPresent" in col]  
    columns_to_drop += [col for col in df.columns if "_Both_notPresent" in col]  
    columns_to_drop += [col for col in df.columns if "_PassedCourse" in col]  
    
      
    df = df.drop(columns=columns_to_drop)

    if "Credits-Y1" in df.columns:

        df["BSA_Compare"]= (df["Credits-Y1"] >= 42).astype(int)

    return df


def AddDefaultRuleToDF(df):
    cluster_labels = (df["Crd-B1B2"] >= 18).astype(int)
    df["#Default"] = cluster_labels
    return df

def AddModelToDF(trainModel: TrainModel.TrainedModel,Name:str,df,df_Pred):
    df_test = df_Pred


    model = trainModel.model
    selected_columns = trainModel.columns
    if "Credits-Y1" in df_test.columns:
        df_test = df_test.drop(columns=["Credits-Y1"])

    if "BSA" in df_test.columns:
        df_test = df_test.drop(columns=["BSA"])

    try: 
        df_test = df_test[selected_columns]
    except:
        print("Error! not all selected columns")
        df[f"#{Name}"] = -1

    imputer = SimpleImputer(strategy="mean")
    imputed_df = pd.DataFrame(imputer.fit_transform(df_test), columns=df_test.columns)


    cluster_labels = model.predict(imputed_df)

    df[f"#{Name}"] = cluster_labels
    missing_indices = df_test.isnull().any(axis=1)


    for index, is_missing in missing_indices.items():
        if is_missing:
            df.loc[index,f"#{Name}"] = -1


    return df 
