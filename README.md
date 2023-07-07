# Passe sanitaire et mobilisation politique sur Twitter : Étude comparative des registres rhétoriques et des réseaux des militants et sympathisants des majeurs partis politiques français

Ce travail repose sur une série de scripts Python pour la collecte et le traitement des données, ainsi que pour l'analyse du langage naturel. De plus, le langage R a été utilisé pour la visualisation des données et l'analyse du réseau.

## Scripts Python

### Collecte et traitement des données
Les scripts Python pour la collecte et le traitement des données sont : 
1. `base.py` : Ce script constitue la base de notre travail, il traite les fichiers de données collectées pour juillet 2021. Sur un total de 5 687 556 tweets, le programme a retenu 6903 messages Twitter.
2. `filter.py` et `filter_filtered.py` : Ces scripts sont utilisés pour le nettoyage des données.
3. `annotation.py` : Ce script est utilisé pour l'annotation de l'affiliation politique.
4. `filter_Bis.py` : Ce script permet de filtrer la base de données en fonction des résultats obtenus avec le script précédent.
5. `last_base.py` : Ce script est utilisé pour obtenir la base d'analyse finale.

### Analyse du langage naturel
Le script `nlp.py` a été utilisé pour charger et filtrer les données par affiliation politique, permettant ainsi une analyse distincte pour chaque parti. Il a également été utilisé pour calculer des mesures telles que la fréquence des n-grammes, la représentation TF-IDF, une matrice de similarité cosinus, et pour visualiser les plongements de mots en utilisant la technique t-SNE.

## Scripts R

Le script `Description.R` a été utilisé pour construire et visualiser le réseau de retweets, en utilisant la bibliothèque igraph de R pour créer un graphique orienté à partir du dataframe edges.

## Bibliothèques utilisées
Python :
- matplotlib 3.7.1
- nltk 3.8.1
- numpy 1.24.2
- pandas 1.5.3
- scikit-learn 1.2.2
- scipy 1.10.1
- spacy 3.5.3

R :
- tidyverse 1.3.2
- tidyr 1.2.1
- dplyr 1.0.10
- gtsummary 1.6.2
- scales 1.2.1
- gt 0.8.0
- forcats 0.5.2
- tibble 3.1.8
- stringr 1.4.1
- scales 1.2.1
- igraph 1.3.5
- leaflet 2.1.1
- sf 1.0-9
- kableExtra 1.3.4
- gsubfn 0.7
- lubridate 1.9.0
- igraph 1.3.5
- nnet 7.3-18
