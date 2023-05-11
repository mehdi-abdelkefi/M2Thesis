import pandas as pd

# Load filtered user bios
user_bio_path = "data/filtered_user_bio.csv"
user_bio = pd.read_csv(user_bio_path)

# Load party criteria files
party_output_paths = {
    'Agir': 'data/Agir_output.txt',
    'EELV': 'data/EELV_output.txt',
    'GRS': 'data/GRS_output.txt',
    'LFI': 'data/LFI_output.txt',
    'LR': 'data/LR_output.txt',
    'MRSL': 'data/MRSL_output.txt',
    'MoDem': 'data/MoDem_output.txt',
    'PCF': 'data/PCF_output.txt',
    'PS': 'data/PS_output.txt',
    'Place_Publique': 'data/Place_Publique_output.txt',
    'RN': 'data/RN_output.txt',
    'UDI': 'data/UDI_output.txt',
}

# Create new columns for each party
for party, file_path in party_output_paths.items():
    with open(file_path, 'r') as f:
        usernames = [line.strip() for line in f.readlines()]
        user_bio[party] = user_bio["from_user_name"].isin(usernames).astype(int)

# Save updated user bio file
updated_user_bio_path = "updated_user_bios.csv"
user_bio.to_csv(updated_user_bio_path, index=False)
