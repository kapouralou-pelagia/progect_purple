# για να συγκεντρωσουμε ολα τα assemblies απο του διαφορερτικους assmblers μαζι 
autocycler compress \
  --assemblies_dir autocycler/SRL1098/input \
  --autocycler_dir autocycler/SRL1098/compress
# συγκριση ολων των assemblies μεταξυ τους 
  autocycler cluster \
  --autocycler_dir autocycler/SRL1098/compress
  #trimming 
  autocycler trim \
  --cluster_dir autocycler/SRL1098/compress/clustering/qc_pass/cluster_001
  # μετατροπη σε fasta 
  mkdir -p autocycler/SRL1098/final

awk '/^S/{print ">"$2"\n"$3}' \
autocycler/SRL1098/compress/clustering/qc_pass/cluster_001/5_final.gfa \
> autocycler/SRL1098/final/SRL1098_autocycler.fasta
