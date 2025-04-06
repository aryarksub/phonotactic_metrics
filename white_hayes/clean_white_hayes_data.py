import pandas as pd

dir = "white_hayes/"

# Clean test data
df = pd.read_csv(f"{dir}white_hayes_2012.csv").dropna(subset="LogResponse")
ratings = list(df["LogResponse"])
subjects = list(df["Subject"])
df["ARPA"].to_csv(f"{dir}white_hayes_cleaned_test_data.csv", header=False, index=False)

# Find words with zero unigram probability
df_metric = pd.read_csv(f"{dir}white_hayes_original_metric_output.csv")
ind_invalid = df_metric.index[df_metric["uni_prob"] == float('-inf')].tolist()
print("Words with -inf uni_prob:", set(df_metric["word"].loc[ind_invalid]))

# Replace invalid ARPABET in test dataset
# Words with zero unigram prob: {'T W I K AH N', 'C AH N IH F L'}
df.replace({"T W I K AH N" : "T W IH K AH N", "C AH N IH F L" : "K AH N IH F L"}, inplace=True)
df["ARPA"].to_csv(f"{dir}white_hayes_cleaned_fixed_test_data.csv", header=False, index=False)

# Clean fixed metric output csv
def clean_metric_output(pre=''):
    df_metric = pd.read_csv(f"{dir}{pre}white_hayes_fixed_metric_output.csv")
    df_metric.replace(float('-inf'), -20, inplace=True)
    df_metric["rating"] = ratings
    if "subject" not in df_metric.columns:
        df_metric.insert(loc=0, column="subject", value=subjects)
    df_metric.to_csv(f"{dir}{pre}white_hayes_cleaned_metric_output.csv", index=False)

clean_metric_output()
clean_metric_output('new_')