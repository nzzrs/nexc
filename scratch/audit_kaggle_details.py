import os
import pandas as pd

print("Listing exercisedb_v1_sample:")
sample_dir = "/home/nzrs/.cache/kagglehub/datasets/exercisedb/fitness-exercises-dataset/versions/4/exercisedb_v1_sample"
if os.path.exists(sample_dir):
    print(os.listdir(sample_dir))
    for f in os.listdir(sample_dir):
        fp = os.path.join(sample_dir, f)
        if os.path.isfile(fp):
            print(f"\nFile: {f}")
            if f.endswith('.csv'):
                print(pd.read_csv(fp).head(2))
            elif f.endswith('.json'):
                print(pd.read_json(fp).head(2))
else:
    print("sample_dir does not exist")

print("\n--- Detailed Audit for omarxadel/fitness-exercises-dataset ---")
csv1 = "/home/nzrs/.cache/kagglehub/datasets/omarxadel/fitness-exercises-dataset/versions/1/exercises.csv"
if os.path.exists(csv1):
    df = pd.read_csv(csv1)
    print("Unique body parts:", df['bodyPart'].unique())
    print("Unique targets:", df['target'].unique())
    print("Unique equipment:", df['equipment'].unique())
    print("Sample gifUrl values:\n", df['gifUrl'].head(5).tolist())
    print("Sample row 0:\n", df.iloc[0].dropna().to_dict())

print("\n--- Detailed Audit for edoardoba/fitness-exercises-with-animations ---")
csv2 = "/home/nzrs/.cache/kagglehub/datasets/edoardoba/fitness-exercises-with-animations/versions/3/fitness_exercises.csv"
if os.path.exists(csv2):
    df = pd.read_csv(csv2)
    print("Sample gifUrl values:\n", df['gifUrl'].head(5).tolist())
    print("Sample row 0:\n", df.iloc[0].to_dict())
