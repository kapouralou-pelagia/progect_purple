total=0; count=0
for f in *.fasta; do
    echo "Processing: $f"
    n=$(grep -v '^>' "$f" | wc -m)
    total=$((total+n))
    count=$((count+1))
done

echo "Total files: $count"
echo "Total bases: $total"
echo "Average per assembly: $((total/count))"