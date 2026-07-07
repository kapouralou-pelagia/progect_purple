#!/usr/bin/env bash
set -euo pipefail

THREADS=12
OUTBASE="antismash_results"

SAMPLES="SRL1098 SRL1112 SRL1123 SRL1260 SRL1263 SRL1264 SRL1433 SRL917"

mkdir -p "$OUTBASE"

for s in $SAMPLES
do
    INPUT="bakta_annotations/$s/$s.embl"
    OUTDIR="$OUTBASE/$s"

    echo "=================================="
    echo "Running antiSMASH for $s"
    echo "Input: $INPUT"
    echo "Output: $OUTDIR"
    echo "=================================="

    if [ ! -f "$INPUT" ]; then
        echo "ERROR: Bakta EMBL file not found for $s: $INPUT"
        continue
    fi

    antismash "$INPUT" \
        --cpus "$THREADS" \
        --output-dir "$OUTDIR" \
        --cc-mibig \
        --cb-general \
        --enable-genefunctions \
        --cb-subclusters \
        --cb-knownclusters \
        --enable-lanthipeptides \
        --enable-lassopeptides \
        --enable-nrps-pks \
        --enable-sactipeptides \
        --enable-t2pks \
        --enable-thiopeptides \
        --enable-tta

    echo "Finished antiSMASH for $s"
done

echo "All antiSMASH analyses finished."


