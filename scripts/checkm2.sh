#!/usr/bin/env bash
set -euo pipefail

THREADS=12
OUTBASE="checkm2_results"

SAMPLES="SRL1098 SRL1112 SRL1123 SRL1260 SRL1263 SRL1264 SRL1433 SRL917"

mkdir -p "$OUTBASE"

for s in $SAMPLES
do
    ASSEMBLY="assemblies/$s/flye/assembly.fasta"
    OUTDIR="$OUTBASE/$s"

    echo "=================================="
    echo "Running CheckM2 for $s"
    echo "Assembly: $ASSEMBLY"
    echo "Output: $OUTDIR"
    echo "=================================="

    if [ ! -f "$ASSEMBLY" ]; then
        echo "ERROR: Assembly not found for $s: $ASSEMBLY"
        continue
    fi

    mkdir -p "$OUTDIR"

    checkm2 predict \
        --threads "$THREADS" \
        --input "$ASSEMBLY" \
        --output-directory "$OUTDIR" \
        --force

    echo "Finished CheckM2 for $s"
done

echo "All CheckM2 analyses finished."
