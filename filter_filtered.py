import pandas as pd
import os

# Define the paths to the files
data_dir = os.path.join(os.getcwd(), "data")
user_bio_path = os.path.join(data_dir, "user_bios.csv")
no_party_path = os.path.join(data_dir, "no_party_output.txt")

# Load the dataframes
user_bio = pd.read_csv(user_bio_path)
with open(no_party_path, "r") as f:
    no_party_usernames = [username.strip() for username in f.readlines()]

# Filter out the matching rows
user_bio = user_bio[~user_bio["from_user_name"].isin(no_party_usernames)]

# Save the updated dataframe to a new file
filtered_user_bio_path = os.path.join(data_dir, "filtered_user_bio.csv")
user_bio.to_csv(filtered_user_bio_path, index=False)

print("Filtered user bio data saved to", filtered_user_bio_path)
