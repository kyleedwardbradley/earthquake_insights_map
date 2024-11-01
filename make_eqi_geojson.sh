#!/usr/bin/env bash 

# Create GeoJSON template file for Earthquake Insights interactive Leaflet map
# Usage:
# ./make_eqi_geojson.sh

# We get urls of published posts from posts.csv in the Substack data download ZIP file. 

# Post locations must be added manually to a file called url_coords.csv:
# Fields:
# url                                ,lon    ,lat    ,mag, status
# how-does-seismic-hazard-vary-across,28.9748,41.0130,0,"always"

# Currently, only status="always" is used. 
# Symbols on the map are scaled by mag, minimum=5

# 3d_models.csv is a comma-separated file with these fields:
# uid,lon,lat,date

# 9c38a08933154e128bb550246285f9e4,-119.1,35.0,2024-08-07T00:00:00


gawk < posts.csv -F, '($3=="true"){print $1 "\t" $2}' | cut -c11-1000 | gawk -F '\t' '{print  $1 "," $2}' | sort -t ',' -k 2 > posts_pre.csv

 gawk -F, '
    BEGIN {
        printf("{\n\"type\": \"FeatureCollection\",\n\t\"features\": [\n");
        first=1
    }
    (ARGIND==1) {
        found[$1]=1
        lon[$1]=$2
        lat[$1]=$3
        mag[$1]=$4
        status[$1]=$5
    }
    (ARGIND==2){
        if (found[$1]!=1) {
            next
        }

        if (first==0) {
            printf(",\n")
        } else {
            first=0
            printf("\n")
        }
        printf("\t{\n")
        printf("\t\t\"type\": \"Feature\",\n")
        printf("\t\t\"geometry\": {\n")
        printf("\t\t\t\"type\": \"Point\",\n")
        printf("\t\t\t\"coordinates\": [" lon[$1]+0 "," lat[$1]+0 "]\n")
        printf("\t\t},\n")
        printf("\t\t\"properties\": {\n")
        printf("\t\t\t\"size\": \"large\",\n")
        printf("\t\t\t\"date\": \"" $2 "\",\n")
        printf("\t\t\t\"url\": \"" $1 "\",\n")
        if (status[$1] == "always") {
            printf("\t\t\t\"status\": \"always\",\n")
        } else {
            printf("\t\t\t\"status\": \"paid\",\n")
        }
        # printf("\t\t\t\"status\": \"none\",\n")
        printf("\t\t\t\"uid\": \"none\",\n")
        printf("\t\t\t\"mag\": \"" mag[$1]+0 "\"\n")
        printf("\t\t}\n")
        printf("\t}")
    }
    ' url_coords.csv posts_pre.csv > posts.geojson

# This is a new list of URLs that arent in posts.csv, so we don't have to re-download our
# Substack archive each time a post is added.

gawk -F, '
    (ARGIND==1) {
        found[$1]=1
        date[$1]=$2
        lon[$1]=$3
        lat[$1]=$4
        mag[$1]=$5
        status[$1]=$6
    
        printf(",\n\t{\n")
        printf("\t\t\"type\": \"Feature\",\n")
        printf("\t\t\"geometry\": {\n")
        printf("\t\t\t\"type\": \"Point\",\n")
        printf("\t\t\t\"coordinates\": [" lon[$1]+0 "," lat[$1]+0 "]\n")
        printf("\t\t},\n")
        printf("\t\t\"properties\": {\n")
        printf("\t\t\t\"size\": \"large\",\n")
        printf("\t\t\t\"date\": \"" date[$1] "\",\n")
        printf("\t\t\t\"url\": \"" $1 "\",\n")
        if (status[$1] == "always") {
            printf("\t\t\t\"status\": \"always\",\n")
        } else {
            printf("\t\t\t\"status\": \"paid\",\n")
        }
        printf("\t\t\t\"uid\": \"none\",\n")
        printf("\t\t\t\"mag\": \"" mag[$1]+0 "\"\n")
        printf("\t\t}\n")
        printf("\t}")
    }
    ' new_url_coords.csv >> posts.geojson



gawk < 3d_models.csv -F, '
    {
        if (NR!=1) {
            printf(",\n")
        } else {
            printf(",\n")
        }

        printf("\t{\n")
        printf("\t\t\"type\": \"Feature\",\n")
        printf("\t\t\"geometry\": {\n")
        printf("\t\t\t\"type\": \"Point\",\n")
        printf("\t\t\t\"coordinates\": [" $2 "," $3 "]\n")
        printf("\t\t},\n")
        printf("\t\t\"properties\": {\n")
        printf("\t\t\t\"size\": \"large\",\n")
        printf("\t\t\t\"date\": \"" $4 "\",\n")
        printf("\t\t\t\"url\": \"none\",\n")
        printf("\t\t\t\"status\": \"paid\",\n")
        printf("\t\t\t\"uid\": \"" $1 "\",\n")
        printf("\t\t\t\"title\": \"" $5 "\"\n")
        
        printf("\t\t}\n")
        printf("\t}")
    }
    END {
        printf("\n\t]\n}\n")
    }' > 3dmodels.geojson

# Edit the posts.geojson file and save as posts_edited.geojson

cat posts.geojson 3dmodels.geojson > posts_final.geojson

# rm -f posts.geojson 3dmodels.geojson posts_pre.csv