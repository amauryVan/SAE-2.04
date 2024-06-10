#!/bin/bash

# Vérifier si le nom de fichier CSV est passé en argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <nom_fichier_csv>"
    exit 1
fi

# Nom du fichier CSV (passé en argument)
nom_fichier_csv="$1"
# Nom du fichier Excel de sortie
nom_fichier_xls="dico.xls"

# Extraire les noms de colonnes du fichier CSV
noms_colonnes=$(head -n 1 "$nom_fichier_csv" | tr ';' '\n')

# Compter le nombre de colonnes
nb_colonnes=$(echo "$noms_colonnes" | wc -l)

# Créer le fichier Excel
printf "Numero de colonne\tNom de la colonne\n" > "$nom_fichier_xls"
for ((i = 1; i <= nb_colonnes; i++)); do
    nom_colonne=$(echo "$noms_colonnes" | sed -n "${i}p")
    printf "%d\t%s\n" "$i" "$nom_colonne" >> "$nom_fichier_xls"
done

echo "Le fichier Excel a été créé avec succès."

