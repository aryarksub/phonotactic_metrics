import pandas as pd
import numpy as np

dir = "albright/"

# Clean test data
df = pd.read_csv(f"{dir}albright_hayes_2003.csv")
df.replace("F LEH", "F L EH T", inplace=True)
df.rename(columns={"Verb_apra" : "verb_arpa", "Phonological Well-Formedness Rating (PhonWF)" : "PhonWF"}, inplace=True)
df.dropna(subset=["verb_arpa"], inplace=True)
ratings = list(df["PhonWF"])
df["verb_arpa"].to_csv(f"{dir}albright_cleaned_test_data.csv", header=False, index=False)

# Clean metric output csv
def clean_metric_output(pre=''):
    df = pd.read_csv(f"{dir}{pre}albright_original_metric_output.csv")
    df.replace(float('-inf'), -50, inplace=True)
    df["rating"] = ratings
    df.to_csv(f"{dir}{pre}albright_cleaned_metric_output.csv", index=False)

clean_metric_output()
clean_metric_output('new_')