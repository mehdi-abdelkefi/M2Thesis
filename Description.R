######## Load libraries#########
library(tidyverse)
library(tidyr)
library(dplyr)
library(gtsummary)
library(scales)
library(gt)
library(forcats)
library(tibble)
library(stringr)
library(scales)
library(igraph)
library(leaflet)
library(sf)
library(kableExtra)
library(gsubfn)
library(lubridate)
library(igraph)
library(nnet)


theme_gtsummary_language ("fr", decimal.mark = ",", big.mark = "")
theme_gtsummary_mean_sd()


########## Read CSV file#########
setwd("~/Desktop/")
base_nlp <- read.csv("Thesis_M2/output.csv", sep = ";")

base_nlp <- base_nlp %>%
  select(-retweet_count, -favorite_count, -reply_count)

# Fill empty columns with NA in base_nlp
base_nlp <- base_nlp %>%
  mutate(across(everything(), ~ ifelse(. == "", NA, .)))

# Function to count occurrences of multiple values separated by "|"
count_occurrences <- function(x) {
  ifelse(is.na(x), 0, lengths(str_split(x, "\\|")))
}

# Add the counts to each row in base_nlp
base_nlp <- base_nlp %>%
  mutate(
    links_count = sapply(links, count_occurrences),
    medias_urls_count = sapply(medias_urls, count_occurrences),
    mentioned_user_names_count = sapply(mentioned_user_names, count_occurrences)
  )

base_nlp$tweet <- ifelse(is.na(base_nlp$retweeted_user_name) | base_nlp$retweeted_user_name == "", 1, 0)
base_nlp$retweet <- ifelse(is.na(base_nlp$retweeted_user_name) | base_nlp$retweeted_user_name == "", 0, 1)
base_nlp$target_tweet <- ifelse(is.na(base_nlp$to_user_name) | base_nlp$to_user_name == "", 0, 1)

# Create new variables for picture and video links count
base_nlp$picture_links_count <- sapply(strsplit(base_nlp$medias_urls, "\\|"), 
                                       function(x) sum(grepl("https://pbs.twimg.com/media/.*\\.jpg", x)))
base_nlp$video_links_count <- sapply(strsplit(base_nlp$medias_urls, "\\|"), 
                                     function(x) sum(grepl("https://video.twimg.com/ext_tw_video/.*\\.mp4", x)))

## Recoding base_nlp$hashtags_count into base_nlp$hashtags_count_rec
base_nlp$hashtags_count_rec <- base_nlp$hashtags_count %>%
  as.character() %>%
  fct_recode(
    "Un seul" = "1",
    "Deux à cinq" = "2",
    "Deux à cinq" = "3",
    "Deux à cinq" = "4",
    "Deux à cinq" = "5",
    "Six à dix" = "6",
    "Six à dix" = "7",
    "Six à dix" = "8",
    "Six à dix" = "9",
    "Six à dix" = "10",
    "Dix ou plus" = "11",
    "Dix ou plus" = "12",
    "Dix ou plus" = "13",
    "Dix ou plus" = "14",
    "Dix ou plus" = "15",
    "Dix ou plus" = "16",
    "Dix ou plus" = "17",
    "Dix ou plus" = "18",
    "Dix ou plus" = "19",
    "Dix ou plus" = "21",
    "Dix ou plus" = "23",
    "Dix ou plus" = "25",
    "Dix ou plus" = "27"
  )


# Define party levels
party_levels <- c(
  "LREM",
  "MoDem",
  "Agir",
  "LR",
  "RN",
  "UDI",
  "LFI",
  "PCF",
  "Generation.s",
  "PS",
  "Place Publique",
  "EELV",
  "Generation Ecologie",
  "MRSL",
  "Nouvelle Donne",
  "Ensemble!",
  "GRS"
)

# Set Party column as a factor with defined levels
base_nlp$Party <- factor(base_nlp$Party, levels = party_levels)

# Define party colors
party_colors <- c(
  "LREM" = "#FFDB58",
  "MoDem" = "#A0B7DA",
  "Agir" = "#5F9EA0",
  "LR" = "#B0171F",
  "RN" = "#002395",
  "UDI" = "#FFA500",
  "LFI" = "#CC3333",
  "PCF" = "#FF69B4",
  "Generation.s" = "#3CB371",
  "PS" = "#FFC0CB",
  "Place Publique" = "#FF7F50",
  "EELV" = "#00FF00",
  "Generation Ecologie" = "#008000",
  "MRSL" = "#8B0000",
  "Nouvelle Donne" = "#800080",
  "Ensemble!" = "#FFA07A",
  "GRS" = "#4B0082",
  "Autres partis de droite" = "#A0B7DA",
  "Autres partis de gauche" = "#3CB371"
  
)

###### Plot 1 Chap. 3 #####
party_counts_df <- base_nlp %>%
  distinct(from_user_name, Party) %>%
  count(Party) %>%
  arrange(desc(n))

total_tweets <- sum(party_counts_df$n)

# calculate the total number of users
total_users <- sum(party_counts_df$n)

plot_users_party <- ggplot(party_counts_df, aes(x = fct_inorder(Party), y = n, fill = Party)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = n), vjust = -0.5, size = 4) +
  geom_text(aes(label = paste0(round((n / total_users) * 100, 1), "%")), 
            vjust = 1.6, color = "black", size = 3.5) +
  scale_fill_manual(values = party_colors) +
  labs(title = "Répartition des utilisateurs selon l'affiliation partisane",
       x = "Parti Politique",
       y = "Nombre d'utilisateurs") +
  theme(plot.title = element_text(size = 18, face = "bold"),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12, angle = 45, hjust = 1),
        legend.position = "none",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

plot_users_party
ggsave("users_party.pdf", plot_users_party, width = 9, height = 6)




###### Plot 3 CHAP. 3########
# calculate the total number of tweets
tweet_counts_df <- base_nlp %>%
  group_by(Party) %>%
  summarise(n_tweets = n(), .groups = "keep")

plot_tweets_party <- ggplot(tweet_counts_df, aes(x = reorder(Party, -n_tweets), y = n_tweets, fill = Party)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = n_tweets), vjust = -0.5, size = 4) +
  geom_text(aes(label = paste0(round((n_tweets / total_tweets) * 100, 1), "%")),
            vjust = 1.6, color = "black", size = 3.5) +
  scale_fill_manual(values = party_colors) +
  labs(title = "Répartition des tweets selon l'affiliation partisane",
       x = "Parti Politique",
       y = "Nombre de tweets") +
  theme(plot.title = element_text(size = 18, face = "bold"),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12, angle = 45, hjust = 1),
        legend.position = "none",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

plot_tweets_party
ggsave("tweets_party.pdf", plot_tweets_party, width = 9, height = 6)




####### POPULATION BASE ########
base_pop <- base_nlp %>%
  group_by(from_user_name) %>%
  summarise_all(list(~ if_else(any(is.na(.)), "", paste(unique(.), collapse = "; "))), 
                cols = c("Party", "Party_rec", "from_user_verified")) %>%
  ungroup() %>%
  column_to_rownames(var = "from_user_name")

# Then, for the from_user_verified variable we need to convert it back to numeric
base_pop$from_user_verified <- as.numeric(base_pop$from_user_verified)
# Replace empty values with "NA" in media_urls, links, and retweeted_user_name
base_pop$medias_urls[base_pop$medias_urls == " "] <- NA
base_pop$links[base_pop$links == " "] <- NA
base_pop$retweeted_user_name[base_pop$retweeted_user_name == " "] <- NA

# Count total number of medias urls for each user
base_pop$media_count <- sapply(strsplit(base_pop$medias_urls, ";"), function(x) sum(x != ""))

# Count total number of links for each user
base_pop$link_count <- sapply(strsplit(base_pop$links, ";"), function(x) sum(x != ""))

# Count total number of retweets for each user
base_pop$retweets_count <- sapply(strsplit(base_pop$retweeted_user_name, ";"), function(x) sum(x != ""))

# Count total number of mentions for each user
base_pop$mentions_count <- sapply(strsplit(base_pop$mentioned_user_names, ";"), function(x) sum(str_count(x, "\\|") + 1))


### Count total number of hashtags for each user
# Split the hashtags_count values by semicolon
split_hashtags <- strsplit(base_pop$hashtags_count, "; ")

# Calculate the total number of hashtags for each tweet and store in a new column
base_pop$hashtags_total_count <- sapply(split_hashtags, function(x) sum(as.integer(x), na.rm = TRUE))

# Calculate total number of text for each user
base_pop$text_count <- sapply(strsplit(base_pop$text, "; "), length)

base_nlp_grouped <- base_nlp %>%
  group_by(from_user_name) %>%
  summarise(
    mean_followers = mean(from_user_followercount, na.rm = TRUE),
    mean_tweets = mean(from_user_tweetcount, na.rm = TRUE),
    mean_favourites = mean(from_user_favourites_count, na.rm = TRUE),
    mean_friends = mean(from_user_friendcount, na.rm = TRUE)
  )

base_pop <- base_nlp %>%
  distinct(from_user_name) %>%
  left_join(base_nlp_grouped, by = "from_user_name") %>%
  mutate(
    links_count = sapply(from_user_name, function(x) sum(base_nlp$links_count[base_nlp$from_user_name == x])),
    medias_urls_count = sapply(from_user_name, function(x) sum(base_nlp$medias_urls_count[base_nlp$from_user_name == x])),
    mentioned_user_names_count = sapply(from_user_name, function(x) sum(base_nlp$mentioned_user_names_count[base_nlp$from_user_name == x])),
    tweet = sapply(from_user_name, function(x) sum(base_nlp$tweet[base_nlp$from_user_name == x])),
    retweet = sapply(from_user_name, function(x) sum(base_nlp$retweet[base_nlp$from_user_name == x])),
    hashtags_count = sapply(from_user_name, function(x) sum(base_nlp$hashtags_count[base_nlp$from_user_name == x])),
    from_user_verified = sapply(from_user_name, function(x) base_nlp$from_user_verified[base_nlp$from_user_name == x][1]),
    Party = sapply(from_user_name, function(x) base_nlp$Party[base_nlp$from_user_name == x][1]),
    target_tweet = sapply(from_user_name, function(x) base_nlp$target_tweet[base_nlp$from_user_name == x][1]),
    pic_links_count = sapply(from_user_name, function(x) sum(base_nlp$picture_links_count[base_nlp$from_user_name == x])),
    vid_links_count = sapply(from_user_name, function(x) sum(base_nlp$video_links_count[base_nlp$from_user_name == x]))
  )


base_verified <- base_nlp %>%
  filter(from_user_verified != 0)


verified_accounts <- base_verified %>%
  group_by(from_user_name, Party) %>%
  summarize(mean_follower_count = mean(from_user_followercount), .groups = "drop")



######### PLOT 2 CHAP. 3 ############
# Calculate verified user count per party
verified_counts <- base_verified %>%
  group_by(Party) %>%
  summarise(n_verified = n(), .groups = "keep")

# Add the count to the original data frame
base_verified <- left_join(base_verified, verified_counts, by = "Party")

# plot data with the parties ordered by verified user count
plot_box_plots <- ggplot(base_verified, aes(x = fct_reorder(Party, -n_verified), y = from_user_tweetcount, fill = Party)) +
  geom_boxplot() +
  labs(title = "Analyse comparative de l'activité des utilisateurs vérifiés sur Twitter par affiliation politique",
       x = "Parti politique",
       y = "Nombre total de tweets") +
  scale_fill_manual(name = "Parti politique", values = party_colors) +
  theme(plot.title = element_text(size = 18, face = "bold"),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12))
plot_box_plots
ggsave("plot_box_plots.pdf", plot_box_plots, width = 16, height = 8)



## Recoding verified_accounts$from_user_name into verified_accounts$PER_ORG
verified_accounts$PER_ORG <- verified_accounts$from_user_name %>%
  fct_recode(
    "0" = "AgirEnsemble_AN",
    "1" = "AgnesEvren",
    "1" = "ALouisDeputee13",
    "1" = "BrunoBilde",
    "1" = "CarolineFiat54",
    "1" = "CCastaner",
    "1" = "CharlesPrats",
    "1" = "claireopetit",
    "1" = "denis_Masseglia",
    "0" = "deputesPCF",
    "0" = "DeputesUDI_Ind",
    "1" = "F_Charvier",
    "1" = "fabien_gay",
    "0" = "FranceInsoumise",
    "1" = "GaelLeBohec",
    "1" = "GillesPennelle",
    "1" = "GrudlerCh",
    "1" = "iacovellixavier",
    "1" = "J_Bardella",
    "0" = "J_Democrates",
    "1" = "JeanPierrePont",
    "1" = "jerome_riviere",
    "1" = "JLMelenchon",
    "1" = "JulienOdoul",
    "1" = "larrouturou",
    "0" = "lesRepublicains",
    "1" = "ludovicMDS",
    "1" = "Michel_Larive",
    "1" = "mnlienemann",
    "0" = "MoDem",
    "1" = "moreaujb23",
    "1" = "NicolasBay_",
    "1" = "NMeizonnet",
    "1" = "npouzyreff78",
    "1" = "OlgaGivernet",
    "0" = "PCF",
    "1" = "PhilippeMichelK",
    "1" = "PoncetRaymonde",
    "1" = "RachidTemal",
    "0" = "Renaissance_UE",
    "0" = "Republicains_An",
    "1" = "RixainMP",
    "1" = "RKokouendoJ",
    "0" = "RNational_off",
    "1" = "RolandLescure",
    "1" = "RSCactu",
    "1" = "senateur61",
    "0" = "senateursCRCE",
    "1" = "Stephane_Ravier",
    "1" = "stephane1peu",
    "1" = "ThierryBenoit35",
    "1" = "valerieboyer13",
    "1" = "wdesaintjust",
    "1" = "yfavennec"
  )

##### TABLE 1 ANNEXE ######
verified_persons_table <- verified_accounts %>%
  filter(PER_ORG == "1") %>%
  group_by(Party) %>%
  arrange(desc(mean_follower_count)) %>%
  mutate(row_number = row_number()) %>%
  ungroup() %>%
  arrange(desc(mean_follower_count), Party) %>%
  group_by(Party) %>%
  mutate(users = paste0(ifelse(row_number == 1, "\textbf{", ""), from_user_name, ifelse(row_number == 1, "}", "")),
         follower_counts = ifelse(row_number == 1, paste0("\textbf{", round(mean_follower_count), "}"), round(mean_follower_count))) %>%
  ungroup() %>%
  select(Party, users, follower_counts) %>%
  rename(`Parti politique` = Party, `Nom d'utilisateur`= users, `Nombre moyen de followers`= follower_counts)

verified_persons_table
kable(verified_persons_table, format = "latex", caption = "Comptes Twitter vérifiés (Personnes) : ordre décroissant des noms d'utilisateurs en fonction du nombre moyen de followers") %>%
kable_styling(bootstrap_options = c("striped", "hover"), full_width = FALSE)

###### TABLE 2 ANNEXE ############
verified_orgs_table <- verified_accounts %>%
filter(PER_ORG == "0") %>%
group_by(Party) %>%
arrange(desc(mean_follower_count)) %>%
mutate(row_number = row_number()) %>%
ungroup() %>%
arrange(desc(mean_follower_count), Party) %>%
group_by(Party) %>%
mutate(users = paste0(ifelse(row_number == 1, "\textbf{", ""), from_user_name, ifelse(row_number == 1, "}", "")),
follower_counts = ifelse(row_number == 1, paste0("\textbf{", round(mean_follower_count), "}"), round(mean_follower_count))) %>%
ungroup() %>%
select(Party, users, follower_counts) %>%
  rename(`Parti politique` = Party, `Nom d'utilisateur`= users, `Nombre moyen de followers`= follower_counts)

kable(verified_orgs_table, format = "latex", caption = "Comptes Twitter vérifiés (Organisations) : ordre décroissant des noms d'utilisateurs en fonction du nombre moyen de followers") %>%
kable_styling(bootstrap_options = c("striped", "hover"), full_width = FALSE)


##### TABLE 1 CHAP. 3 ######
most_followed_persons <- verified_persons_table %>%
  filter(str_detect(`Nom d'utilisateur`, "^\\textbf"), str_detect(`Nombre moyen de followers`, "^\\textbf"))

##### TABLE 2 CHAP. 3 ######
most_followed_orgs <- verified_orgs_table %>%
  filter(str_detect(`Nom d'utilisateur`, "^\\textbf"), str_detect(`Nombre moyen de followers`, "^\\textbf"))


most_followed_persons %>%
  kable(format = "latex", caption = "Most followed persons") %>%
  kable_styling(bootstrap_options = c("striped", "hover"), full_width = FALSE)

most_followed_orgs %>%
  kable(format = "latex", caption = "Most followed organizations") %>%
  kable_styling(bootstrap_options = c("striped", "hover"), full_width = FALSE)


verified_user_grouped <- base_verified %>%
  group_by(from_user_name) %>%
  summarise(
    mean_followers = mean(from_user_followercount, na.rm = TRUE),
    mean_tweets = mean(from_user_tweetcount, na.rm = TRUE),
    mean_favourites = mean(from_user_favourites_count, na.rm = TRUE),
    mean_friends = mean(from_user_friendcount, na.rm = TRUE)
  )

base_pop_verified <- base_verified %>%
  distinct(from_user_name) %>%
  left_join(verified_user_grouped, by = "from_user_name") %>%
  mutate(
    links_count = sapply(from_user_name, function(x) sum(base_verified$links_count[base_verified$from_user_name == x])),
    medias_urls_count = sapply(from_user_name, function(x) sum(base_verified$medias_urls_count[base_verified$from_user_name == x])),
    mentioned_user_names_count = sapply(from_user_name, function(x) sum(base_verified$mentioned_user_names_count[base_verified$from_user_name == x])),
    tweet = sapply(from_user_name, function(x) sum(base_verified$tweet[base_verified$from_user_name == x])),
    retweet = sapply(from_user_name, function(x) sum(base_verified$retweet[base_verified$from_user_name == x])),
    hashtags_count = sapply(from_user_name, function(x) sum(base_verified$hashtags_count[base_verified$from_user_name == x])),
    from_user_verified = sapply(from_user_name, function(x) base_verified$from_user_verified[base_verified$from_user_name == x][1]),
    Party_rec = sapply(from_user_name, function(x) base_verified$Party_rec[base_verified$from_user_name == x][1]),
    Party = sapply(from_user_name, function(x) base_verified$Party[base_verified$from_user_name == x][1]),
    target_tweet = sapply(from_user_name, function(x) base_verified$target_tweet[base_verified$from_user_name == x][1]),
    pic_links_count = sapply(from_user_name, function(x) sum(base_verified$picture_links_count[base_verified$from_user_name == x])),
    vid_links_count = sapply(from_user_name, function(x) sum(base_verified$video_links_count[base_verified$from_user_name == x]))
  )



###### TABLE 3 CHAP. 3 ###############  
# Compute count per party and trim spaces from Party names
party_counts <- base_pop_verified %>%
  mutate(Party = str_trim(Party, side = "both")) %>%
  filter(!(tolower(Party) %in% tolower(c("Generation.s", "Place Publique", "MRSL", "Ensemble!", "Generation Ecologie")))) %>%
  group_by(Party) %>%
  summarise(n = n(), .groups = "drop") %>%
  arrange(-n)

# Filter out unrepresented parties and order the levels of Party according to the counts
filtered_verified_table <- base_pop_verified %>%
  mutate(Party = str_trim(Party, side = "both")) %>%
  filter(!(tolower(Party) %in% tolower(c("Generation.s", "Place Publique", "MRSL", "Ensemble!", "Generation Ecologie")))) %>%
  mutate(Party = factor(Party, levels = party_counts$Party))

# Then proceed with creating table as before
verified_user_table <- filtered_verified_table %>% 
  tbl_summary(
    include = c("mean_followers",
                "mean_tweets",
                "mean_friends",
                "mean_favourites"
    ),
    by = Party,
    label = list(mean_followers = "Nombre de followers",
                 mean_tweets = "Nombre total de tweets",
                 mean_friends = "Nombre de personnes suivies",
                 mean_favourites = "Nombre de tweets favoris"
    ),
    statistic = all_continuous() ~ paste("{mean}", "\n ±{sd}"),
    digits = all_continuous() ~ c(0, 0),
    missing = "ifany",
    missing_text = "Sans réponse"
  ) %>% 
  add_n() %>% 
  add_p() # This will perform a t-test or ANOVA based on the number of groups

verified_user_table

latex_verified_table <- as_gt(verified_user_table) %>%
  as_latex()
print(latex_verified_table)

######### TABLE 4 CHAP. 3 ###########
# Filter base_pop to include only non-verified users and exclude specified parties
filtered_non_verified_table <- base_pop %>%
  filter(from_user_verified == 0) %>%
  mutate(Party = str_trim(Party, side = "both")) %>%
  filter(!(tolower(Party) %in% tolower(c("Generation.s", "Place Publique", "MRSL", "Ensemble!", "Generation Ecologie"))))

# Count the number of non-verified users for each party
party_counts <- filtered_non_verified_table %>%
  count(Party) %>%
  arrange(desc(n))

# Use these counts to reorder the factor levels of 'Party'
filtered_non_verified_table$Party <- factor(filtered_non_verified_table$Party, 
                                            levels = party_counts$Party)

# Now create the summary table
non_verified_user_table <- filtered_non_verified_table %>% 
  tbl_summary(
    include = c("mean_followers",
                "mean_tweets",
                "mean_friends",
                "mean_favourites"
    ),
    by = Party,
    label = list(mean_followers = "Nombre de followers",
                 mean_tweets = "Nombre total de tweets",
                 mean_friends = "Nombre de personnes suivies",
                 mean_favourites = "Nombre de tweets favoris"
    ),
    statistic = all_continuous() ~ paste("{mean}", "\n ±{sd}"),
    digits = all_continuous() ~ c(0, 0),
    missing = "ifany",
    missing_text = "Sans réponse"
  ) %>% 
  add_n() %>% 
  add_p()

non_verified_user_table

latex_non_verified_table <- as_gt(non_verified_user_table) %>%
  as_latex()
print(latex_non_verified_table)


####### Plot 4 CHAP. 3 #######
# Convert `created_at` to a Date object
base_nlp$created_at <- as.Date(ymd_hms(base_nlp$created_at))

# Filter tweets made in July
tweets_in_july <- base_nlp %>%
  filter(month(created_at) == 7)

# Count tweets by day and party
daily_tweets <- tweets_in_july %>%
  group_by(created_at, Party) %>%
  summarise(tweet_count = n(), .groups = 'drop')

# Create the line chart
tweet_plot <- ggplot(daily_tweets, aes(x = created_at, y = tweet_count, color = Party)) +
  geom_line() +  # Utiliser des lignes pour représenter le nombre de tweets au fil du temps
  scale_x_date(date_breaks = "1 day", date_labels = "%d %b") +  # Formater l'axe des x avec des dates
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +  # Incliner les étiquettes de l'axe des x pour une meilleure lisibilité
  labs(
    x = "Date (Juillet 2021)", 
    y = "Nombre de Tweets", 
    title = "Nombre de Tweets par Parti au cours du Temps",
    color = "Parti"
  ) +
  scale_color_manual(values = party_colors)
tweet_plot
  
ggsave("tweets_time.pdf", plot = tweet_plot, width = 12, height = 6)

## Recoding base_nlp$Party into base_nlp$Party_rec
base_nlp$Party_rec <- base_nlp$Party %>%
  fct_recode(
    "Autres partis de droite" = "MoDem",
    "Autres partis de droite" = "Agir",
    "Autres partis de droite" = "UDI",
    "Autres partis de gauche" = "Generation.s",
    "Autres partis de gauche" = "Place Publique",
    "Autres partis de gauche" = "EELV",
    "Autres partis de gauche" = "Generation Ecologie",
    "Autres partis de gauche" = "MRSL",
    "Autres partis de gauche" = "Nouvelle Donne",
    "Autres partis de gauche" = "Ensemble!",
    "Autres partis de gauche" = "GRS",
    "Autres partis de gauche" = "PS"
  )

base_pop$Party_rec <- base_pop$Party %>%
  fct_recode(
    "Autres partis de droite" = "MoDem",
    "Autres partis de droite" = "Agir",
    "Autres partis de droite" = "UDI",
    "Autres partis de gauche" = "Generation.s",
    "Autres partis de gauche" = "Place Publique",
    "Autres partis de gauche" = "EELV",
    "Autres partis de gauche" = "Generation Ecologie",
    "Autres partis de gauche" = "MRSL",
    "Autres partis de gauche" = "Nouvelle Donne",
    "Autres partis de gauche" = "Ensemble!",
    "Autres partis de gauche" = "GRS",
    "Autres partis de gauche" = "PS"
  )


plot_box_plots_hashtags <- ggplot(base_nlp, aes(x = Party_rec, y = hashtags_count, fill = Party)) +
  geom_boxplot() +
  labs(title = "Analyse comparative de l'utilisation des hashtags par affiliation politique",
       x = "Parti politique",
       y = "Nombre de hashtags par tweet") +
  scale_fill_manual(name = "Parti politique", values = party_colors) +
  theme(plot.title = element_text(size = 18, face = "bold"),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12))

plot_box_plots_hashtags
ggsave("plot_box_plots_hashtags.pdf", plot_box_plots_hashtags, width = 16, height = 8)


##### TABLE 5 CHAP. 3 #########
party_counts <- base_pop %>%
  mutate(Party_rec = str_trim(Party_rec, side = "both")) %>%
  group_by(Party_rec) %>%
  summarise(n = n(), .groups = "drop") %>%
  arrange(-n)

# Filter out unrepresented parties and order the levels of Party_rec according to the counts
base_pop <- base_pop %>%
  mutate(Party_rec = str_trim(Party_rec, side = "both")) %>%
  mutate(Party_rec = factor(Party_rec, levels = party_counts$Party_rec))

# Calculate frequencies
freq_table <- table(base_pop$tweet, base_pop$retweet, base_pop$target_tweet, base_pop$from_user_verified)


# Create tbl_summary
user_party_table2 <- base_pop %>%
  tbl_summary(
    include = c("tweet", "retweet", "target_tweet", "from_user_verified"),
    by = Party_rec,
    label = list(
      tweet = "Tweets",
      retweet = "Tweets retweetés",
      target_tweet = "Tweets ciblés",
      from_user_verified = "Utilisateurs vérifiés"
    ),
    statistic = all_categorical() ~ "{n} ({p}%)",
    digits = all_categorical() ~ c(0, 0),
    missing = "ifany",
    missing_text = "Sans réponse",
    percent = "row"
  ) %>%
  add_n() 

user_party_table2



######### TABLE 5 CH. 3 ##############
user_party_table_freq <- base_pop %>%
  group_by(Party_rec) %>%
  summarize(
    hashtags_count = sum(as.numeric(hashtags_count), na.rm = TRUE),
    mentioned_user_names_count = sum(as.numeric(mentioned_user_names_count), na.rm = TRUE),
    retweet = sum(as.numeric(retweet), na.rm = TRUE),
    links_count = sum(as.numeric(links_count), na.rm = TRUE),
    medias_urls_count = sum(as.numeric(medias_urls_count), na.rm = TRUE),
    tweet = sum(as.numeric(tweet), na.rm = TRUE)
  ) %>%
  ungroup() %>%
  mutate(across(c(hashtags_count:tweet),
                ~ paste0(round(as.numeric(.)), " (", round(100 * as.numeric(.) / sum(as.numeric(.))), "%)"))) %>%
  pivot_longer(cols = -Party_rec, names_to = "Variable", values_to = "Value") %>%
  pivot_wider(names_from = "Party_rec", values_from = "Value") %>%
  slice(6, 3, 1, 2, 4, 5) %>%
  mutate(Variable = recode(Variable, 
                           hashtags_count = "Hashtags",
                           mentioned_user_names_count = "Utilisateurs mentionnés",
                           retweet = "Tweets retweetés",
                           links_count = "Liens",
                           medias_urls_count = "Médias",
                           tweet = "Tweets"
  ))
user_party_table_freq



####### TABLE 6 CH. 3 ##########
## Recoding base_nlp$picture_links_count into base_nlp$picture_links_count_rec
base_nlp$picture_links_count <- base_nlp$picture_links_count %>%
  as.character() %>%
  fct_recode(
    "Pas de photos" = "0",
    "Une seule" = "1",
    "Deux ou plus" = "2",
    "Deux ou plus" = "3",
    "Deux ou plus" = "4"
  )
## Recoding base_nlp$links_count into base_nlp$links_count_rec
base_nlp$links_count <- base_nlp$links_count %>%
  as.character() %>%
  fct_recode(
    "Pas de liens" = "0",
    "Un seul" = "1",
    "Deux ou plus" = "2",
    "Deux ou plus" = "3"
)
party_populations <- base_nlp %>%
  count(Party_rec) %>%
  arrange(desc(n))
base_nlp$Party_rec <- factor(base_nlp$Party_rec, levels = party_populations$Party_rec)

tweet_party_table <- base_nlp %>%
  tbl_summary(
    include = c("tweet", "retweet", "from_user_verified", "links_count", "picture_links_count", "video_links_count", "hashtags_count_rec"),
    by = Party_rec,
    label = list(
      tweet = "Tweets",
      retweet = "Tweets retweetés",
      from_user_verified = "Utilisateurs vérifiés",
      hashtags_count_rec = "Hashtags",
      links_count = "Liens externes",
      picture_links_count = "Photos téléversées",
      video_links_count = "Vidéos téléversés"
    ),
    statistic = all_categorical() ~ "{p}% (obs. {n})",
    digits = all_categorical() ~ c(0, 0),
    missing = "ifany",
    missing_text = "Sans réponse",
    percent = "row"
  ) %>%
  add_n() %>%
  add_p(simulate.p.value = TRUE)
tweet_party_table

latex_code <- tweet_party_table %>%
  as_kable_extra(format = "latex")
print(latex_code)



###########TAB. REG (#) CHAP. 3 ##################
regression_data <- base_nlp %>%
  select(links_count, picture_links_count, video_links_count, hashtags_count_rec, Party_rec)

regression_data$links_count <- factor(regression_data$links_count, levels = c("Un seul", "Deux ou plus", "Pas de liens"))
regression_data$picture_links_count <- factor(regression_data$picture_links_count, levels = c("Pas de photos", "Une seule", "Deux ou plus"))
regression_data$Party_rec <- factor(regression_data$Party_rec)
regression_data$video_links_count <- factor(regression_data$video_links_count)

# Specify reference modalities for variables
regression_data$links_count <- relevel(regression_data$links_count, ref = "Pas de liens")
regression_data$picture_links_count <- relevel(regression_data$picture_links_count, ref = "Pas de photos")
regression_data$Party_rec <- relevel(regression_data$Party_rec, ref = "LREM")

# Fit the regression model
regression_model <- multinom(hashtags_count_rec ~ links_count + picture_links_count + video_links_count + Party_rec, data = regression_data)



tableau_reg_1 <- regression_model %>%
  tbl_regression(
    intercept = TRUE,
    include = c(
      links_count, picture_links_count, video_links_count, Party_rec
    ),
    label = list(
      links_count = "Liens externes",
      picture_links_count = "Photos téléversées",
      video_links_count = "Vidéo téléversé",
      Party_rec = "Party"
    )
  )
tableau_reg_1

# Extraire les coefficients et les erreurs standard
coefficients <- coef(regression_model)
std_errors <- sqrt(diag(vcov(regression_model)))

# Créer un objet tbl_regression manuellement
tbl_regression <- tbl_regression(
  coef_data = coefficients,
  se = std_errors,
  exponentiate = TRUE, # Afficher les exp(coef) (rapports de cotes) au lieu des coeficients bruts
  label = list(
    links_count = "Liens externes",
    picture_links_count = "Photos téléversées",
    video_links_count = "Vidéo téléversée",
    Party_rec = "Parti"
  )
)

# Modifier les en-têtes des colonnes
tbl_regression <- modify_header(
  tbl_regression,
  statistic = "**Std. Error**" # Modifier l'en-tête de l'erreur standard
)

# Afficher le tableau final
tbl_regression


################### NETWORK ANALYSIS ########################
# Extract relevant columns from base_nlp
edges <- base_nlp[c("from_user_name", "retweeted_user_name", "Party_rec")]

# Filter out rows with missing or NA values in the user columns
edges <- edges[complete.cases(edges[, c("from_user_name", "retweeted_user_name")]), ]

usernames <- unique(edges$from_user_name)
usernames
matching_users <- base_pop$from_user_name[base_pop$from_user_name %in% usernames]
# Convert Source and Label columns to factors
edges$from_user_name <- as.factor(edges$from_user_name)
edges$Party_rec <- as.factor(edges$Party_rec)

# Create the graph from the edges dataframe
graph <- graph.data.frame(edges, directed = TRUE)

# # Create the CSV file
# csv_file <- "edges.csv"
# 
# # Write the header
# header <- c("Source, Target, Color, Name")
# writeLines(header, csv_file)
# 
# # Write the data rows
# data_rows <- paste0('"', edges$from_user_name, '", "', edges$retweeted_user_name, '", "', edges$Party_rec, '", "', edges$retweeted_user_name, '"')
# write(data_rows, csv_file, append = TRUE, sep = "\n")
# 
# # Output a success message
# cat("CSV file created successfully:", csv_file)


setwd("~/memoire_M2/")

edges <- read.csv("Edges.csv")
nodes <- read.csv("Nodes.csv")

graph <- graph.data.frame(edges, directed = TRUE, vertices = nodes)



modularity_classes <- nodes$modularity_class

table(modularity_classes)

lookup_table <- setNames(nodes$Id, nodes$modularity_class)
lookup_table

# Create a new data frame with user names and modularity classes
user_modularity <- data.frame(User_Name = nodes$Id, Modularity_Class = nodes$modularity_class)

# Group the data by modularity classes and collect the user names
grouped_data <- user_modularity %>%
  group_by(Modularity_Class) %>%
  summarise(User_Names = toString(User_Name))

# Print the new grouping
print(grouped_data)


# Split the user names in the grouped_data data frame
split_data <- grouped_data %>%
  mutate(User_Names = strsplit(User_Names, ", ")) %>%
  unnest(User_Names)

# Join with the base_nlp data to match Party_rec values
merged_data <- split_data %>%
  left_join(base_nlp, by = c("User_Names" = "from_user_name")) %>%
  select(Modularity_Class, Party_rec) %>%
  filter(!is.na(Party_rec))

# Count the occurrences of Party_rec within each modularity class
party_counts <- merged_data %>%
  count(Modularity_Class, Party_rec) %>%
  ungroup()

# Identify unidentified Party_rec values
unidentified <- split_data %>%
  filter(!User_Names %in% merged_data$User_Names) %>%
  mutate(Party_rec = "Unidentified") %>%
  count(Modularity_Class, Party_rec) %>%
  ungroup()

# Combine identified and unidentified Party_rec counts
combined_counts <- bind_rows(party_counts, unidentified)

# Pivot the data to have Party_rec values as columns
pivot_data <- combined_counts %>%
  pivot_wider(names_from = Party_rec, values_from = n, values_fill = 0)

# Calculate row sums
pivot_data <- pivot_data %>%
  mutate(Total_Rows = rowSums(across(-Modularity_Class)))

# Sort the pivot_data table based on total rows
sorted_data <- pivot_data %>%
  arrange(desc(Total_Rows))

# View the sorted table
sorted_data

# Select the top 10 rows
top_10_data <- head(sorted_data, 10)

# Convert the top 10 data to a LaTeX table
latex_table <- kable(top_10_data, format = "latex")

# Print the LaTeX table
cat(latex_table)

# Select rows starting from row 11
subset_data <- sorted_data %>%
  slice(11:n())
# Convert the subset_data table to a LaTeX table
latex_table <- kable(subset_data, format = "latex") %>%
  kable_styling()

# Print the LaTeX table
cat("\\begin{table}\n")
cat("\\centering\n")
cat("\\caption{Your table caption here}\n")
cat("\\label{tab:mytable}\n")
cat(latex_table)
cat("\\end{table}\n")



#### Betweenness #####
# Create an empty graph object
g <- graph.empty(n = nrow(nodes), directed = TRUE)

# Add nodes to the graph
V(g)$name <- nodes$Id
V(g)$Label <- nodes$Label

# Convert edges to a matrix
edges_matrix <- as.matrix(edges[, c("Source", "Target")])

# Get unique node names from edges
all_nodes <- unique(c(edges_matrix[, "Source"], edges_matrix[, "Target"]))

# Add edges to the graph if the vertices exist
for (i in 1:nrow(edges_matrix)) {
  source_node <- edges_matrix[i, "Source"]
  target_node <- edges_matrix[i, "Target"]
  
  if (source_node %in% all_nodes && target_node %in% all_nodes) {
    g <- add_edges(g, c(source_node, target_node))
  }
}

# Add 'modularity_class' attribute to nodes
V(g)$ModularityClass <- nodes$modularity_class

# Compute betweenness centrality for each political party
party_betweenness <- lapply(unique(nodes$modularity_class), function(party) {
  party_nodes <- V(g)$name[V(g)$ModularityClass == party]
  party_subgraph <- subgraph.edges(g, E(g)[from(party_nodes) | to(party_nodes)])
  betweenness(party_subgraph)
})

# Extract the index of the node with maximum betweenness centrality for each party
party_max_index <- lapply(party_betweenness, function(party_bc) {
  max_index <- which.max(party_bc)
  return(max_index)
})

# Get the node names corresponding to the maximum betweenness centrality indices
party_influencers <- lapply(party_max_index, function(max_index) {
  node_name <- V(g)$name[max_index]
  return(node_name)
})

# Combine political party names with their respective influencers
party_influencers <- setNames(party_influencers, unique(nodes$modularity_class))

# Print the most influencing user name for each party
for (party in names(party_influencers)) {
  influencer <- party_influencers[[party]]
  cat("Most influencing user for", party, "is", influencer, "\n")
}




# Create an empty list to store the networks for each political party
party_networks <- list()

# Get unique political parties from the edge list
unique_parties <- unique(edges$color)

# Iterate over each political party
for (party in unique_parties) {
  # Filter edges for the current party
  party_edges <- edges[edges$color == party, c("Source", "Target")]
  
  # Create the graph for the current party
  party_graph <- graph_from_data_frame(d = party_edges, directed = TRUE)
  
  # Store the graph in the party_networks list
  party_networks[[party]] <- party_graph
}

# Create an empty list to store the user names with the highest betweenness value for each party
party_influencers <- list()

# Iterate over each political party
for (party in unique_parties) {
  # Get the graph for the current party
  party_graph <- party_networks[[party]]
  
  # Compute betweenness centrality for the party graph
  party_betweenness <- betweenness(party_graph)
  
  # Find the index of the node with the maximum betweenness centrality
  max_index <- which.max(party_betweenness)
  
  # Get the user name with the highest betweenness value
  influencer <- V(party_graph)$name[max_index]
  
  # Store the user name in the party_influencers list
  party_influencers[[party]] <- influencer
}
party_influencers

# Create an empty list to store the betweenness centrality values for each party
party_betweenness <- list()

# Iterate over each political party
for (party in unique_parties) {
  # Get the graph for the current party
  party_graph <- party_networks[[party]]
  
  # Compute betweenness centrality for the party graph
  party_betweenness[[party]] <- betweenness(party_graph)
}


# Create seven empty data frames, one for each political party
df_party1 <- data.frame(User = character(), Betweenness = numeric(), stringsAsFactors = FALSE)
df_party2 <- data.frame(User = character(), Betweenness = numeric(), stringsAsFactors = FALSE)
df_party3 <- data.frame(User = character(), Betweenness = numeric(), stringsAsFactors = FALSE)
df_party4 <- data.frame(User = character(), Betweenness = numeric(), stringsAsFactors = FALSE)
df_party5 <- data.frame(User = character(), Betweenness = numeric(), stringsAsFactors = FALSE)
df_party6 <- data.frame(User = character(), Betweenness = numeric(), stringsAsFactors = FALSE)
df_party7 <- data.frame(User = character(), Betweenness = numeric(), stringsAsFactors = FALSE)

# Iterate over each political party
for (i in 1:length(unique_parties)) {
  party <- unique_parties[i]
  betweenness_values <- party_betweenness[[party]]
  
  # Create a data frame with the username and betweenness value
  df <- data.frame(User = V(party_networks[[party]])$name, Betweenness = betweenness_values, stringsAsFactors = FALSE)
  
  # Assign the data frame to the corresponding party data frame variable
  assign(paste0("df_party", i), df)
}


########## CH. 5 #########

#### SEE PYTHON CODE 
write.csv(base_nlp, file = "base_nlp.csv", row.names = FALSE)

# Perform frequency analysis of hashtags
frequency_analysis <- table(unlist(strsplit(as.character(base_nlp$hashtags), ",")))

# Sort the frequency analysis in descending order
frequency_analysis <- sort(frequency_analysis, decreasing = TRUE)

# Print the results
print(frequency_analysis)

# Create a list to store the frequency analysis tables for each party
frequency_tables <- list()

# Perform frequency analysis for each party
for (party in unique(base_nlp$Party_rec)) {
  party_data <- base_nlp[base_nlp$Party_rec == party, ]
  party_hashtags <- unlist(strsplit(as.character(party_data$hashtags), ","))
  party_frequency <- table(party_hashtags)
  frequency_tables[[party]] <- party_frequency
}

# Print the results for each party
for (party in unique(base_nlp$Party_rec)) {
  cat("Frequency Analysis for", party, ":\n")
  print(frequency_tables[[party]])
  cat("\n")
}

# Create an empty list to store the frequency data frames for each party
frequency_data_frames <- list()

# Perform frequency analysis and create data frames for each party
for (party in unique(base_nlp$Party_rec)) {
  party_data <- base_nlp[base_nlp$Party_rec == party, ]
  party_hashtags <- unlist(strsplit(as.character(party_data$hashtags), ","))
  party_frequency <- table(party_hashtags)
  sorted_frequency <- sort(party_frequency, decreasing = TRUE)
  party_df <- data.frame(hashtag = names(sorted_frequency), frequency = as.numeric(sorted_frequency))
  frequency_data_frames[[party]] <- party_df
}

# Print the results for each party
for (party in unique(base_nlp$Party_rec)) {
  cat("Frequency Analysis for", party, ":\n")
  print(frequency_data_frames[[party]])
  cat("\n")
}

# Export each data frame to a separate CSV file
for (party in unique(base_nlp$Party_rec)) {
  filename <- paste0("frequency_", party, ".csv")
  write.csv(frequency_data_frames[[party]], file = filename, row.names = FALSE)
}


table(base_nlp$Party_rec)
table(base_nlp$links_count, base_nlp$Party_rec)
