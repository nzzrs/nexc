import os
import kagglehub
import pandas as pd

def audit_dataset(dataset_handle):
    print(f"\n=========================================\nAuditing dataset: {dataset_handle}")
    try:
        path = kagglehub.dataset_download(dataset_handle)
        print("Downloaded to:", path)
        files = os.listdir(path)
        print("Files in dataset:", files)
        
        # Check files inside
        for f in files:
            file_path = os.path.join(path, f)
            if os.path.isdir(file_path):
                print(f"Directory: {f} contains {len(os.listdir(file_path))} items")
            elif f.endswith('.csv'):
                df = pd.read_csv(file_path)
                print(f"\nCSV file: {f}")
                print("Shape:", df.shape)
                print("Columns:", list(df.columns))
                print("First 3 records:")
                print(df.head(3))
            elif f.endswith('.json'):
                print(f"\nJSON file: {f}")
                try:
                    df = pd.read_json(file_path)
                    print("Shape:", df.shape)
                    print("Columns:", list(df.columns))
                    print("First 3 records:")
                    print(df.head(3))
                except Exception as ex:
                    print("Could not read JSON as pandas DataFrame:", ex)
    except Exception as e:
        print(f"Error auditing {dataset_handle}:", e)

# Audit the three datasets
audit_dataset("exercisedb/fitness-exercises-dataset")
audit_dataset("omarxadel/fitness-exercises-dataset")
audit_dataset("edoardoba/fitness-exercises-with-animations")
