import re
import os
import pandas as pd


input_dir = 'data'
output_file = "output.csv"

columns = [
    "created_at",
    "from_user_name",
    "text",
    "retweet_count",
    "favorite_count",
    "reply_count",
    "to_user_name",
    "source_url",
    "location",
    "from_user_verified",
    "from_user_description",
    "from_user_tweetcount",
    "from_user_followercount",
    "from_user_friendcount",
    "from_user_favourites_count",
    "retweeted_user_name",
    "links",
    "medias_urls",
    "mentioned_user_names",
    "hashtags"
]

hashtags = [
    "#passe_sanitaire",
    "#PassSanitaire",
    "#pass_sanitaire",
    "#PasseSanitaire",
    "#Passe_sanitaire",
    "#Passe_Sanitaire",
    "#Pass_Sanitaire",
    "#Pass_sanitaire",
    "#passsanitaire",
    "#passesanitaire"
]

terms = [
    # Majority Coalition
    "La République En Marche", "LREM", "Macron", "macron", "EM", "macroniste", "Emmanuel Macron"
    "Mouvement Démocrate", "MoDem", "Bayrou",
    "Agir",

    # Opposition Coalition
    "Les Républicains", "LR",
    "Rassemblement National", "RN", "Le Pen", "Marine Le Pen",
    "Union des Démocrates et Indépendants", "UDI",

    # Left-wing Coalition
    "La France Insoumise", "LFI", "Jean-Luc Mélenchon", "Mélenchon", "melenchon", "JLM",
    "Parti Communiste Français", "PCF",
    "Génération.s", "Hamon",
    "Parti Socialiste", "PS", "Hollande",
    "Place Publique", "Raphaël Glucksmann", "Glucksmann"

    # Ecologist Coalition
    "Europe Écologie Les Verts", "EELV", "Yannick Jadot", "Jadot",
    "Génération écologie", "Delphine Batho", "Batho"
    "Mouvement Radical Social et Liberal", "MRSL",

    # New Ecologist and Social Union Coalition (NUPES)
    "Nouvelle Donne", "Larrouturou",
    "Ensemble!", "Clémentine Autain", "Autain"
    "Gauche Républicaine et Socialiste", "GRS",

    # Additional politicians
    "Édouard Philippe", "Philippe"
    "Jean Castex", "Castex"
    "Gabriel Attal", "Attal"
    "Olivier Véran", "veran",
    "lepen",
    "Xavier Bertrand", "Bertrand"
    "Valérie Pécresse", "Pecresse", "Pécresse"
    "Christian Estrosi", "Estrosi"
    "Gérald Darmanin", "Darmanin"
    "Anne Hidalgo", "Hidalgo"
]

party_terms = {
    "La République En Marche": "LREM",
    "LREM": "LREM",
    "Macron": "LREM",
    "macron": "LREM",
    "EM": "LREM",
    "macroniste": "LREM",
    "Emmanuel Macron": "LREM",
    "Mouvement Démocrate": "MoDem",
    "MoDem": "MoDem",
    "Bayrou": "MoDem",
    "Agir": "Agir",
    "Les Républicains": "LR",
    "LR": "LR",
    "Rassemblement National": "RN",
    "RN": "RN",
    "Le Pen": "RN",
    "Marine Le Pen": "RN",
    "Union des Démocrates et Indépendants": "UDI",
    "UDI": "UDI",
    "La France Insoumise": "LFI",
    "LFI": "LFI",
    "Jean-Luc Mélenchon": "LFI",
    "Mélenchon": "LFI",
    "melenchon": "LFI",
    "JLM": "LFI",
    "Parti Communiste Français": "PCF",
    "PCF": "PCF",
    "Génération.s": "Generations",
    "Hamon": "Generations",
    "Parti Socialiste": "PS",
    "PS": "PS",
    "Hollande": "PS",
    "Place Publique": "Place_Publique",
    "Raphaël Glucksmann": "Place_Publique",
    "Glucksmann": "Place_Publique",
    "Europe Écologie Les Verts": "EELV",
    "EELV": "EELV",
    "Yannick Jadot": "EELV",
    "Jadot": "EELV",
    "Génération écologie": "Generation_Ecologie",
    "Delphine Batho": "Generation_Ecologie",
    "Batho": "Generation_Ecologie",
    "Mouvement Radical Social et Liberal": "MRSL",
    "MRSL": "MRSL",
    "Nouvelle Donne": "Nouvelle_Donne",
    "Larrouturou": "Nouvelle_Donne",
    "Ensemble!": "Ensemble",
    "Clémentine Autain": "Ensemble",
    "Autain": "Ensemble",
    "Gauche Républicaine et Socialiste": "GRS",
    "GRS": "GRS",
    "Édouard Philippe": "Other",
    "Philippe": "Other",
    "Jean Castex": "Other",
    "Castex": "Other",
    "Gabriel Attal": "Other",
    "Attal": "Other",
    "Olivier Véran": "Other",
    "veran": "Other",
    "lepen": "RN",
    "Xavier Bertrand": "Other",
    "Bertrand": "Other",
    "Valérie Pécresse": "Other",
    "Pecresse": "Other",
    "Pécresse": "Other",
    "Christian Estrosi": "Other",
    "Estrosi": "Other",
    "Gérald Darmanin": "Other",
    "Darmanin": "Other",
    "Anne Hidalgo": "Other",
    "Hidalgo": "Other"
}

# Create a regex pattern for hashtags
hashtags_regex = r'\b(' + '|'.join(hashtags) + r')\b'

# Create a regex pattern for party terms
regex = r'\b(' + '|'.join(terms) + r')\b'


def get_party(bio):
    if bio is None:
        return None

    for term, party in party_terms.items():
        if term.lower() in bio.lower():
            return party
    return None


total_input_rows = 0
rows_count = 0

df = pd.DataFrame(columns=columns + ["hashtags_count"])
df.to_csv(output_file, index=False)

# Read no_party_output.txt and store the usernames in a set
with open('data/no_party_output.txt', 'r') as f:
    exclude_usernames = set(line.strip() for line in f)

# Discover party criteria files and store the usernames in a dictionary
party_usernames = {}
party_file_pattern = re.compile(r'(.*)_output\.txt$')
for filename in os.listdir(input_dir):
    match = party_file_pattern.match(filename)
    if match:
        party = match.group(1)
        with open(os.path.join(input_dir, filename), 'r') as f:
            party_usernames[party] = set(line.strip() for line in f)

# Create an output directory if it doesn't exist
output_dir = "output"
if not os.path.exists(output_dir):
    os.makedirs(output_dir)


# Function to create an output file for each party
def create_output_file(party):
    output_path = os.path.join(output_dir, f"{party}_output.csv")
    df = pd.DataFrame(columns=columns + ["hashtags_count", "party"])
    df.to_csv(output_path, index=False)
    return output_path


# Create output files for each party and store their paths in a dictionary
party_output_paths = {party: create_output_file(party) for party in party_terms.values()}

for filename in os.listdir(input_dir):
    if filename.endswith(".csv"):
        filepath = os.path.join(input_dir, filename)
        data = pd.read_csv(filepath, usecols=columns)

        total_input_rows += len(data.index)

        data['hashtags_count'] = data['hashtags'].str.count(r'\|') + 1

        # Filter data based on the hashtags
        data = data[data['text'].str.contains('|'.join(hashtags), na=False)]

        filtered_data = data[data['from_user_description'].str.contains(regex, case=False, na=False)]

        filtered_data['party'] = filtered_data['from_user_description'].apply(get_party)

        # Exclude rows with usernames in no_party_output.txt
        filtered_data = filtered_data[~filtered_data['from_user_name'].isin(exclude_usernames)]

        for party, usernames in party_usernames.items():
            filtered_data.loc[filtered_data['from_user_name'].isin(usernames), 'party'] = party

            # Write the filtered data to separate output files based on the user party
        for party, output_path in party_output_paths.items():
            party_data = filtered_data[filtered_data['party'] == party]
            party_data.to_csv(output_path, mode='a', header=False, index=False)
            rows_count += len(party_data.index)

print(f'Total rows in the input files: {total_input_rows}')
print(f'Total rows in the output files: {rows_count}')

