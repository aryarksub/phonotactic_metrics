from ngram_calculator import run_calculator

MODELS = [
    ['../uci_phonotactic_calculator/data/english_freq.csv', 'albright/albright_cleaned_test_data.csv', 'albright/albright_new.csv'],
    ['../uci_phonotactic_calculator/data/english_freq.csv', 'daland/daland-test-data.csv', 'daland/daland_new.csv'],
    ['needle/needle_cleaned_training.txt', 'needle/needle_test_data.csv', 'needle/needle_new.csv'],
    ['polish/cleaned_polish_training_data.txt', 'polish/cleaned_polish_test_data.csv', 'polish/polish_new.csv'],
    ['scholes/onset_training_data.csv', 'scholes/scholes_cleaned_test_data.csv', 'scholes/scholes_new.csv'],
    ['spanish/spanish_training_data_stressed.csv', 'spanish/spanish_test_data.csv', 'spanish/spanish_new.csv'],
    ['turkish/turkish_training_data.csv', 'turkish/turkish_test_data.csv', 'turkish/turkish_new.csv'],
    ['../uci_phonotactic_calculator/data/english_freq.csv', 'white_hayes/white_hayes_cleaned_fixed_test_data.csv', 'white_hayes/white_hayes_new.csv']
]
for train, test, out in MODELS:
    run_calculator(train, test, out)
