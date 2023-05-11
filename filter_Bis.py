import os
import glob
import pandas as pd

def read_csv_files(path):
    """
    Reads all csv files in a directory and concatenates them into a single dataframe.
    """
    csv_files = glob.glob(os.path.join(path, '*.csv'))
    all_data = pd.concat([pd.read_csv(f) for f in csv_files], ignore_index=True)
    return all_data

def extract_usernames_and_bios(dataframe):
    """
    Extracts the unique from_user_name and corresponding from_user_description for each user.
    Returns a new dataframe with the unique usernames and bios.
    """
    usernames = []
    bios = []
    for _, row in dataframe.iterrows():
        username = row["from_user_name"]
        if username not in usernames:
            usernames.append(username)
            bio = row["from_user_description"]
            bios.append(bio)
    return pd.DataFrame({"from_user_name": usernames, "from_user_description": bios})

def extract_party_data(path):
    """
    Extracts the unique from_user_name and corresponding from_user_description for each party.
    Returns a dictionary with party names as keys and dataframes as values.
    """
    party_data = {}
    for filename in os.listdir(path):
        if filename.endswith(".csv"):
            party_name = filename.split("_")[0]
            file_path = os.path.join(path, filename)
            df = pd.read_csv(file_path)
            party_data[party_name] = extract_usernames_and_bios(df)
    return party_data

def main():
    # Set paths
    csv_path = "output"
    output_path = "user_bios.csv"

    # Read CSV files
    all_data = read_csv_files(csv_path)

    # Extract party data
    party_data = extract_party_data(csv_path)

    # Combine user bios
    user_bios = pd.concat([df for df in party_data.values()], ignore_index=True)

    # Remove duplicates
    user_bios.drop_duplicates(subset=["from_user_name"], inplace=True)

    # Save to CSV
    user_bios.to_csv(output_path, index=False)

def filter_user_bios(user_bios_file, no_party_file):
    user_bios = pd.read_csv(user_bios_file)

    with open(no_party_file, 'r') as f:
        no_party_usernames = f.read().splitlines()

    user_bios = user_bios[~user_bios['from_user_name'].isin(no_party_usernames)]
    user_bios.to_csv('user_bios_filtered.csv', index=False)

if __name__ == '__main__':
    main()
