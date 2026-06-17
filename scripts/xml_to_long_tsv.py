import os
import xml.etree.ElementTree as ET
import sys
import csv

# folder με XML αρχεία
xml_folder = sys.argv[1]
output_tsv = sys.argv[2]

rows = []

for fname in os.listdir(xml_folder):
    if not fname.endswith(".xml"):
        continue

    sample_path = os.path.join(xml_folder, fname)

    try:
        tree = ET.parse(sample_path)
        root = tree.getroot()
    except:
        print(f"Skipping invalid XML: {fname}")
        continue

    sample_id = fname.replace(".xml", "")

    # Βρες όλα τα SAMPLE_ATTRIBUTE
    for attr in root.findall(".//SAMPLE_ATTRIBUTE"):
        tag = attr.findtext("TAG", default="NA")
        value = attr.findtext("VALUE", default="NA")
        rows.append([sample_id, tag, value])

# γράφει σε long-format TSV
with open(output_tsv, "w", newline="") as out:
    writer = csv.writer(out, delimiter="\t")
    writer.writerow(["sample_id", "tag", "value"])
    writer.writerows(rows)

print(f"Saved long-format metadata to: {output_tsv}")

