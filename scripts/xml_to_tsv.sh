#!/bin/bash

xml_folder="valid_samples_xml"
output_file="samples_from_xml.tsv"

echo -e "Assembly_GCA\tSample_ID" > "$output_file"

for xml in "$xml_folder"/*.xml; do

    gca=$(grep -oE 'GCA_[0-9]+\.[0-9]+' "$xml" | head -n 1)
    sample=$(grep -oE '(SAMEA[0-9]+|SAMD[0-9]+|SRS[0-9]+|ERS[0-9]+|ERX[0-9]+)' "$xml" | head -n 1)

    if [[ -n "$gca" && -n "$sample" ]]; then
        echo -e "${gca}\t${sample}" >> "$output_file"
    fi

done

echo "Finished!"
