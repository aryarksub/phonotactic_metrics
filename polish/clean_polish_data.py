import pandas as pd

dir = "polish/"

# Clean training data

training_file = f"{dir}UCLA_CDS_Typ_AllOnsetsV.txt"

cleaned_lines = []
with open(training_file, 'r') as file:
    for line in file:
        sounds_and_freq = [token.strip() for token in line.split("V")]
        if sounds_and_freq[0]:
            cleaned_lines.append(",".join(sounds_and_freq))

with open(f"{dir}cleaned_polish_training_data.txt", 'w') as file:
    for line in cleaned_lines:
        file.write(line + "\n")

# Clean test data

test_file = f"{dir}IbexHeadsV.txt"

test_words = []
head_to_ortho_dict = dict()

with open(test_file, 'r') as file:
    for line in file:
        tokens = line.strip().split("\t")
        test_word = tokens[0].split("V")[0].strip()
        head_to_ortho_dict[tokens[1]] = test_word
        test_words.append(test_word)

with open(f"{dir}cleaned_polish_test_data.csv", 'w') as file:
    for word in test_words:
        file.write(word + "\n")

# Merge response data with test data orthography

df = pd.read_csv(f"{dir}all_legit_data.csv")
# new_output_scores contains smoothed unigram probs (output_scores does not)
# change pre to empty string '' to operate on original (no unigram smoothing) files
pre = 'new_'
scores_df = pd.read_csv(f"{dir}{pre}output_scores.csv")

score_columns = list(scores_df.columns[2:])

def get_scores(ortho):
    scores_row = scores_df[scores_df['word'] == ortho].iloc[0]
    return pd.Series([scores_row[col] for col in score_columns])

df['ortho'] = df.apply(lambda row : head_to_ortho_dict[row['head']], axis=1)
df[score_columns] = df.apply(lambda row : get_scores(row['ortho']), axis=1)
df.replace(float('-inf'), -50, inplace=True)

df.to_csv(f"{dir}{pre}cleaned_response_data.csv")
