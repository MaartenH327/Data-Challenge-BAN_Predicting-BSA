from sklearn.cluster import KMeans
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score
from sklearn.preprocessing import StandardScaler
from sklearn.neural_network import MLPClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.naive_bayes import GaussianNB
from catboost import CatBoostClassifier
from sklearn.tree import DecisionTreeClassifier
import lightgbm as lgb



import xgboost as xgb

from dataclasses import dataclass
from typing import List

@dataclass
class TrainedModel:
    model: "Model"
    columns: List[str]

    def __init__(self,model,columns: List[str]) -> None:
        self.model = model
        self.columns = columns

def lgbBig(df_train,Credits=False):
    y_train = 0

    if Credits:
        y_train = df_train["Credits-Y1"]
    else:
        y_train = df_train["BSA"]
 
    if "Credits-Y1" in df_train.columns:
        df_train = df_train.drop(columns=["Credits-Y1"])

    if "BSA" in df_train.columns:
        df_train = df_train.drop(columns=["BSA"])

    df_train = df_train.reset_index(drop=True)

    svm = lgb.LGBMClassifier()
    svm.fit(df_train,y_train)

    return TrainedModel(svm,df_train.columns)




def decisionTreeClassifier(df_train,Credits=False):
    y_train = 0

    if Credits:
        y_train = df_train["Credits-Y1"]
    else:
        y_train = df_train["BSA"]
 
    if "Credits-Y1" in df_train.columns:
        df_train = df_train.drop(columns=["Credits-Y1"])

    if "BSA" in df_train.columns:
        df_train = df_train.drop(columns=["BSA"])

    df_train = df_train.reset_index(drop=True)

    svm = DecisionTreeClassifier()
    svm.fit(df_train,y_train)

    return TrainedModel(svm,df_train.columns)



def LRegression(df_train,Credits=False):
    y_train = 0

    if Credits:
        y_train = df_train["Credits-Y1"]
    else:
        y_train = df_train["BSA"]
 
    if "Credits-Y1" in df_train.columns:
        df_train = df_train.drop(columns=["Credits-Y1"])

    if "BSA" in df_train.columns:
        df_train = df_train.drop(columns=["BSA"])

    df_train = df_train.reset_index(drop=True)

    svm = LogisticRegression(max_iter=1000)
    svm.fit(df_train,y_train)

    return TrainedModel(svm,df_train.columns)

def GBM(df_train,Credits=False):
    y_train = 0

    if Credits:
        y_train = df_train["Credits-Y1"]
    else:
        y_train = df_train["BSA"]
 
    if "Credits-Y1" in df_train.columns:
        df_train = df_train.drop(columns=["Credits-Y1"])

    if "BSA" in df_train.columns:
        df_train = df_train.drop(columns=["BSA"])

    df_train = df_train.reset_index(drop=True)

    svm = GradientBoostingClassifier()
    svm.fit(df_train,y_train)

    return TrainedModel(svm,df_train.columns)


def KNeighbor(df_train,Credits=False):
    y_train = 0

    if Credits:
        y_train = df_train["Credits-Y1"]
    else:
        y_train = df_train["BSA"]
 
    if "Credits-Y1" in df_train.columns:
        df_train = df_train.drop(columns=["Credits-Y1"])

    if "BSA" in df_train.columns:
        df_train = df_train.drop(columns=["BSA"])

    df_train = df_train.reset_index(drop=True)

    svm = KNeighborsClassifier(n_neighbors=5)
    svm.fit(df_train,y_train)

    return TrainedModel(svm,df_train.columns)

def NaiveBayes(df_train,Credits=False):
    y_train = 0

    if Credits:
        y_train = df_train["Credits-Y1"]
    else:
        y_train = df_train["BSA"]
 
    if "Credits-Y1" in df_train.columns:
        df_train = df_train.drop(columns=["Credits-Y1"])

    if "BSA" in df_train.columns:
        df_train = df_train.drop(columns=["BSA"])

    df_train = df_train.reset_index(drop=True)

    svm = GaussianNB()
    svm.fit(df_train,y_train)

    return TrainedModel(svm,df_train.columns)



def SVM_Default(df_train,Credits=False):
    y_train = 0

    if Credits:
        y_train = df_train["Credits-Y1"]
    else:
        y_train = df_train["BSA"]
 
    if "Credits-Y1" in df_train.columns:
        df_train = df_train.drop(columns=["Credits-Y1"])

    if "BSA" in df_train.columns:
        df_train = df_train.drop(columns=["BSA"])

    df_train = df_train.reset_index(drop=True)

    svm = SVC(kernel="linear")
    svm.fit(df_train,y_train)

    return TrainedModel(svm,df_train.columns)

def NeuralNetwork_Default(df_train,Credits=False):

    y_train = 0

    if Credits:
        y_train = df_train["Credits-Y1"]
    else:
        y_train = df_train["BSA"]
 
    if "Credits-Y1" in df_train.columns:
        df_train = df_train.drop(columns=["Credits-Y1"])

    if "BSA" in df_train.columns:
        df_train = df_train.drop(columns=["BSA"])



    scaler = StandardScaler()
    # X_scaled = scaler.fit(X)
    # print(X_scaled)
    mlp = MLPClassifier(hidden_layer_sizes=(100,50),max_iter=1000)
    mlp.fit(df_train,y_train)

    return TrainedModel(mlp,df_train.columns)

def XgBoost(df_train,Credits=False):
    y_train = 0

    if Credits:
        y_train = df_train["Credits-Y1"]
    else:
        y_train = df_train["BSA"]
 
    if "Credits-Y1" in df_train.columns:
        df_train = df_train.drop(columns=["Credits-Y1"])

    if "BSA" in df_train.columns:
        df_train = df_train.drop(columns=["BSA"])
  
    
    clf =  xgb.XGBClassifier(n_estimators=2,max_depth=2,learning_rate=1,objective="binary:logistic")
    clf.fit(df_train,y_train)

    return TrainedModel(clf,df_train.columns)


def RandomForest(df_train,Credits=False):
    y_train = 0

    if Credits:
        y_train = df_train["Credits-Y1"]
    else:
        y_train = df_train["BSA"]
 
    if "Credits-Y1" in df_train.columns:
        df_train = df_train.drop(columns=["Credits-Y1"])

    if "BSA" in df_train.columns:
        df_train = df_train.drop(columns=["BSA"])
  
    
    rf = RandomForestClassifier(n_estimators=100,random_state=42)
    rf.fit(df_train,y_train)

    return TrainedModel(rf,df_train.columns)


    









def KMeansWithPlot(df,df_train,df_test):
    if "Credits-Y1" in df_test:
        df_test = df_test.drop(columns=["Credits-Y1"])

    if "BSA" in df_test:
        df_test = df_test.drop(columns=["BSA"])

    if "Credits-Y1" in df_train:
        df_train = df_train.drop(columns=["Credits-Y1"])

    if "BSA" in df_train:
        df_train = df_train.drop(columns=["BSA"])

    df_train = df_train.reset_index(drop=True)

    kmeans = KMeans(n_clusters=2)
    kmeans.fit(df_train)
    cluster_labels = kmeans.predict(df_test)
    df["Predict"] = cluster_labels   

    #true_labels = np.where(df["BSA"] == 1, 1, 0)


    # print("Precision:", precision_score(true_labels, cluster_labels))
    # print("Recall:", recall_score(true_labels, cluster_labels))
    # print("F1_score:", f1_score(true_labels, cluster_labels))
    #Plot(df,cluster_labels)