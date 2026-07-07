mkdir -p assemblies/SRL1098/raven

raven \
  --threads 20 \
  qc_fastp/SRL1098/SRL1098_filtered.fastq.gz \
  > assemblies/SRL1098/raven/assembly.fasta
