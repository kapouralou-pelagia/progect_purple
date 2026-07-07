conda activate autocycler
mkdir -p assemblies/SRL1098/flye

flye \
  --nano-hq qc_fastp/SRL1098/SRL1098_filtered.fastq.gz \
  --out-dir assemblies/SRL1098/flye \
  --threads 20
