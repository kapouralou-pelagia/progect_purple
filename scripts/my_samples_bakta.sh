#!/usr/bin/env bash
set -euo pipefail

DB="/media/sarlab/DATA/databases/bakta_v6.0/db"
THREADS=12
OUTBASE="bakta_annotations"

SAMPLES="SRL1098 SRL1112 SRL1123 SRL1260 SRL1263 SRL1264 SRL1433 SRL917"

mkdir -p "$OUTBASE"

for s in $SAMPLES
do
    ASSEMBLY="assemblies/$s/flye/assembly.fasta"
    OUTDIR="$OUTBASE/$s"
mkdir -p "$OUTDIR"
    echo "=================================="
    echo "Processing sample: $s"
    echo "Assembly: $ASSEMBLY"
    echo "Output: $OUTDIR"
    echo "=================================="

    if [ ! -f "$ASSEMBLY" ]; then
        echo "ERROR: Assembly not found for $s: $ASSEMBLY"
        continue
    fi

    bakta "$ASSEMBLY" \
        --db "$DB" \
        --threads "$THREADS" \
        --output "$OUTDIR" \
        --prefix "$s" \
        --force

    echo "Finished Bakta annotation for $s"
done

echo "All Bakta annotations finished."
