config = {
    "app_name": "Phoneme Neighborhood Density Calculator",
    "headerLength": int('32'),
}

# Define ANSI escape codes for bold and basic colors
rs = '\033[0m'    # Reset
un = '\033[1;4m'  # Underline

bk = '\033[1;30m'  # Black
re = '\033[1;31m'  # Red
gr = '\033[1;32m'  # Green
ye = '\033[1;33m'  # Yellow
bl = '\033[1;34m'  # Blue
ma = '\033[1;35m'  # Magenta
cy = '\033[1;36m'  # Cyan
wh = '\033[1;37m'  # White

def header():
    print(ma + '__' * config['headerLength'], end='')
    print("\n" + rs)

def welcomeSign():
    header()
    print(" \033[104m" + " " * 5 + "\033[0m\033[1m Welcome to \033[33m" +
          config["app_name"] + " \033[104m" + " " * 5 + rs)
    header()

def is_one_phoneme_edit_away(seq1, seq2):
    # Check if two phoneme sequences are one edit away
    m, n = len(seq1), len(seq2)

    if abs(m - n) > 1:
        return False
    if seq1 == seq2:
        return False

    # When lengths are equal, check for one substitution
    if m == n:
        edits = sum(1 for a, b in zip(seq1, seq2) if a != b)
        return edits == 1

    # When lengths differ by one, check for one insertion or deletion
    if m > n:
        longer, shorter = seq1, seq2
    else:
        longer, shorter = seq2, seq1

    i = j = edits = 0
    while i < len(longer) and j < len(shorter):
        if longer[i] != shorter[j]:
            if edits == 1:
                return False
            edits += 1
            i += 1  # Skip the extra phoneme in the longer sequence
        else:
            i += 1
            j += 1

    # Account for extra phoneme at the end
    if i < len(longer):
        edits += 1

    return edits == 1

def generate_one_edit_away_sequences(seq, phoneme_set):
    edits = set()
    seq_length = len(seq)
    # Substitutions
    for i in range(seq_length):
        for phoneme in phoneme_set:
            if phoneme != seq[i]:
                new_seq = seq[:i] + [phoneme] + seq[i+1:]
                edits.add(' '.join(new_seq))
    # Insertions
    for i in range(seq_length + 1):
        for phoneme in phoneme_set:
            new_seq = seq[:i] + [phoneme] + seq[i:]
            edits.add(' '.join(new_seq))
    # Deletions
    if seq_length > 1:
        for i in range(seq_length):
            new_seq = seq[:i] + seq[i+1:]
            edits.add(' '.join(new_seq))
    return edits

def display_help():
    print(gr + "\nHelp - How to Use the Phoneme Neighborhood Density Calculator" + rs)
    print(cy + """
Instructions:
- To find words containing a specific phoneme, enter a single phoneme (e.g., 'AH').
- To find neighboring words (words one phoneme edit away), enter a sequence of phonemes separated by spaces (e.g., 'AH B AE K').
- Type 'list' to display all available phonemes.
- Type 'help' to display this help message again.
- Type 'exit' to quit the program.

Examples:
- Input: 'AH' (single phoneme)
  Output: Lists all words containing the phoneme 'AH'.

- Input: 'AH B AE K' (multiple phonemes)
  Output: Displays neighboring words one phoneme edit away from 'AH B AE K'.

Notes:
- Phonemes should be separated by spaces.
- Phoneme sequences are case-insensitive.
""" + rs)

def main():
    # Specify the phoneme list file location
    phoneme_list_filename = '../data/english.csv'
    try:
        with open(phoneme_list_filename, 'r') as f:
            phoneme_words = [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print(re + "Phoneme list file not found at " + phoneme_list_filename + rs)
        return

    # Convert phoneme words to uppercase for case-insensitive comparison
    phoneme_words_upper = [word.upper() for word in phoneme_words]
    phoneme_word_set = set(phoneme_words_upper)

    # Extract all phonemes present in the phoneme list
    all_phonemes = set()
    for word in phoneme_words_upper:
        phonemes_in_word = word.split()
        all_phonemes.update(phonemes_in_word)
    sorted_phonemes = sorted(all_phonemes)

    while True:
        print(gr + "Enter phonemes to search (single phoneme or multiple phonemes):\n" + rs)
        print(cy + "Available commands:" + rs)
        print(cy + "  - Type " + ma + "'list'" + rs + cy + " to see all possible phonemes")
        print(cy + "  - Type " + ma + "'help'" + rs + cy + " for instructions")
        print(cy + "  - Type " + ma + "'exit'" + rs + cy + " to quit the program" + rs)
        user_input = input(cy + "\nYour input:\n\n" + ma).strip()

        if not user_input or user_input.lower() == 'exit':
            print(gr + "Thank you for using the Phoneme Neighborhood Density Calculator. Goodbye!" + rs)
            break

        # Handle 'help' command
        if user_input.lower() == 'help':
            display_help()
            continue

        # Handle 'list' command to show all phonemes
        if user_input.lower() == 'list':
            print(gr + "\nList of available phonemes:" + rs)
            for phoneme in sorted_phonemes:
                print(cy + phoneme + rs)
            continue

        # Convert input to uppercase and split into phonemes
        user_input_upper = user_input.upper()
        user_phonemes = user_input_upper.split()

        # Check if all phonemes are valid
        invalid_phonemes = [p for p in user_phonemes if p not in all_phonemes]
        if invalid_phonemes:
            print(ye + f"\nThe following phoneme(s) are not in the list: {', '.join(invalid_phonemes)}" + rs)
            print(ye + "Please enter valid phonemes from the list." + rs)
            continue

        if len(user_phonemes) == 1:
            # Single phoneme input: list words containing the phoneme
            phoneme = user_phonemes[0]
            matching_words = []
            for word in phoneme_words:
                word_phonemes = word.upper().split()
                if phoneme in word_phonemes:
                    matching_words.append(word)

            # Sort the matching words alphabetically
            matching_words.sort()

            # Display the results
            print(gr + f"\nWords containing phoneme '{phoneme}':" + rs)
            if matching_words:
                for mw in matching_words:
                    print(cy + f"- {mw}" + rs)
            else:
                # This case should not occur since we have already checked if the phoneme is valid
                print(ye + f"No words found containing the phoneme '{phoneme}'." + rs)

        else:
            # Multiple phonemes input: find neighbors
            user_phoneme_word_upper = ' '.join(user_phonemes)
            # Check if the phoneme word is in the phoneme list
            if user_phoneme_word_upper not in phoneme_word_set:
                breakpoint()
                print(ye + f"The phoneme word '{user_input}' is not in the phoneme list." + rs)
                # Do not proceed; loop back to the input prompt
                continue

            # Generate possible one-edit-away sequences
            neighbor_sequences = generate_one_edit_away_sequences(user_phonemes, all_phonemes)

            # Find valid neighbors in the word set
            neighbors_upper = neighbor_sequences.intersection(phoneme_word_set)

            # Remove the input word if it's in the neighbors
            if user_phoneme_word_upper in neighbors_upper:
                neighbors_upper.remove(user_phoneme_word_upper)

            # Map back to original casing
            neighbors = []
            for neighbor_upper in neighbors_upper:
                index = phoneme_words_upper.index(neighbor_upper)
                neighbors.append(phoneme_words[index])

            # Sort the neighbors alphabetically
            neighbors.sort()

            # Display the results
            print(gr + f"\nNeighborhood Density Results for '{user_input}':" + rs)
            print(cy + f"Total neighbors: {len(neighbors)}" + rs)
            if neighbors:
                print(gr + "Neighbors are:" + rs)
                for neighbor in neighbors:
                    print(cy + f"- {neighbor}" + rs)
            else:
                print(ye + "No neighboring words found." + rs)

if __name__ == "__main__":
    welcomeSign()
    main()
