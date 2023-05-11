import pandas as pd
import glob

# Path to CSV files
file_path = './data/*.csv'

# Read all CSV files and concatenate them into a single DataFrame
all_data = pd.concat([pd.read_csv(f, usecols=['created_at', 'from_user_name', 'text', 'retweet_count',
                                               'favorite_count', 'reply_count', 'to_user_name', 'source_url',
                                               'location', 'from_user_verified', 'from_user_description',
                                               'from_user_tweetcount', 'from_user_followercount',
                                               'from_user_friendcount', 'from_user_favourites_count',
                                               'retweeted_user_name', 'links', 'medias_urls',
                                               'mentioned_user_names', 'hashtags']) for f in glob.glob(file_path)])

# Read 4last_base.csv file and filter it to only include required columns
base_file_path = '~/Desktop/4last_base.csv'
base_data = pd.read_csv(base_file_path, usecols=['from_user_name', 'Party'], sep=';')

# Filter all_data to only include rows where 'text' column contains one of the specified hashtags
hashtags = ["#passe_sanitaire", "#PassSanitaire", "#pass_sanitaire", "#PasseSanitaire",
            "#Passe_sanitaire", "#Passe_Sanitaire", "#Pass_Sanitaire", "#Pass_sanitaire",
            "#passsanitaire", "#passesanitaire"]
all_data = all_data[all_data['text'].str.contains('|'.join(hashtags))]

# Merge base_data with all_data on 'from_user_name' column
merged_data = pd.merge(all_data, base_data, on='from_user_name', how='inner')

# Count the number of hashtags in 'hashtags' column and add it as a new column 'hashtags_count'
merged_data['hashtags'] = merged_data['hashtags'].str.replace('|', ',')
merged_data['hashtags_count'] = merged_data['hashtags'].str.count(',') + 1



# Output the final merged data to a CSV file called output.csv
merged_data.to_csv('output.csv', columns=['created_at', 'from_user_name', 'text', 'retweet_count',
                                           'favorite_count', 'reply_count', 'to_user_name', 'source_url',
                                           'location', 'from_user_verified', 'from_user_description',
                                           'from_user_tweetcount', 'from_user_followercount',
                                           'from_user_friendcount', 'from_user_favourites_count',
                                           'retweeted_user_name', 'links', 'medias_urls',
                                           'mentioned_user_names', 'hashtags', 'hashtags_count', 'Party'], index=False)
