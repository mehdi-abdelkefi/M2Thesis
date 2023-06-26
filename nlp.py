import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.manifold import TSNE
import matplotlib.pyplot as plt
import spacy
from nltk.corpus import stopwords
from sklearn.feature_extraction.text import CountVectorizer
from collections import Counter
import nltk
from nltk.util import ngrams
from nltk.corpus import stopwords

# Load the dataset
data = pd.read_csv('~/PycharmProjects/Code_M_M2/base_nlp.csv')

# Define the list of parties
parties = ['RN', 'LREM', 'LFI', 'LR', 'PCF', 'Autres partis de droite', 'Autres partis de gauche']

# Function to filter the dataset for a specific party
def filter_dataset_by_party(dataset, party):
    return dataset[dataset['Party_rec'] == party]

# Load the French stop words
stop_words = stopwords.words('french')

# Load the French tokenizer from spaCy
nlp = spacy.load('fr_core_news_sm')

# Create a TF-IDF vectorizer with French stop words
vectorizer = TfidfVectorizer(stop_words=stop_words)

# Initialize a dictionary to store the party-wise text
party_text = {}

# Preprocess and collect text for each party
for party in parties:
    party_data = filter_dataset_by_party(data, party)
    party_text[party] = ' '.join([token.lemma_ for doc in nlp.pipe(party_data['text']) for token in doc if not token.is_stop])
# For each party
for party in parties:
    # 1. Collect unique bios
    unique_bios = set(filter_dataset_by_party(data, party)['from_user_description'])

    # 2. Preprocess the bios (we'll just do lowercasing here, you might want to add more preprocessing steps)
    processed_bios = [' '.join([word.lower() for word in nltk.word_tokenize(bio) if word not in stopwords.words('french')]) for bio in unique_bios if isinstance(bio, str)]

    # Get the bigrams for each bio
    trigram = [b for bio in processed_bios for b in ngrams(nltk.word_tokenize(bio), 3)]

    # Get the most common bigrams
    most_common_trigrams = Counter(trigram).most_common(10)

    print(f"For the party {party}, the most common trigrams are:")
    for trigram, count in most_common_trigrams:
        print(f"Trigram: {trigram}, Count: {count}")

# Compute TF-IDF representation for the combined text of all parties
combined_text = list(party_text.values())
tfidf = vectorizer.fit_transform(combined_text)

# Compute cosine similarity between parties
similarity_matrix = cosine_similarity(tfidf)

# Create a similarity dataframe
similarity_df = pd.DataFrame(similarity_matrix, index=parties, columns=parties)
similarity_df.to_csv('~/Desktop/similarity.csv')
print(similarity_df)

# Perform t-SNE on word embeddings
tsne = TSNE(n_components=2, random_state=42, perplexity=4)
word_embeddings = tsne.fit_transform(tfidf.toarray())

# Define the colors for each party
party_colors = {'LREM': 'yellow', 'RN': 'blue', 'LFI': 'red', 'LR': 'darkred',
                'PCF': 'pink', 'Autres partis de droite': 'skyblue', 'Autres partis de gauche': 'green'}

# Plot the word embeddings
plt.figure(figsize=(10, 10))
for i, party in enumerate(parties):
    plt.scatter(word_embeddings[i, 0], word_embeddings[i, 1], color=party_colors[party])
    plt.annotate(party, (word_embeddings[i, 0], word_embeddings[i, 1]), fontsize=8, ha='center')
plt.show()