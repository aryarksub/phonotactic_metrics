import pandas as pd

dir = "daland/"

df = pd.read_csv(f"{dir}daland-scores.csv")

# Clean test data
def clean_word(row):
    word = row["phono_cmu"]
    no_numbers = " ".join([''.join(ch for ch in token if not ch.isdigit()) for token in word.split()])
    return no_numbers.replace("Coda", "").strip()

df["word"] = df.apply(clean_word, axis=1)

df["word"].to_csv(f"{dir}daland-test-data.csv", index=False, header=False)

# Clean metric output csv
def clean_metric_output(pre=''):
    df_metric = pd.read_csv(f"{dir}{pre}daland_original_metric_output.csv")
    df_metric.replace(float('-inf'), -50, inplace=True)
    df_metric["rating"] = df["likert_rating"]
    df_metric.to_csv(f"{dir}{pre}daland_cleaned_metric_output.csv", index=False)

clean_metric_output()
clean_metric_output('new_')
