import os
import pandas as pd
import shutil

# Φάκελος με ΟΛΑ τα assemblies
seq_folder = r"C:\Users\kapos\OneDrive\Υπολογιστής\bash\sequences"

# CSV με assemblies που θέλεις να αφαιρέσεις
csv_path = r"C:\Users\kapos\OneDrive\Υπολογιστής\bash\small_seq.csv"

# Φάκελος όπου θα τα μετακινήσουμε (ώστε να μη σβηστούν κατά λάθος)
remove_folder = r"C:\Users\kapos\OneDrive\Υπολογιστής\bash\removed_assemblies"

# Αν δεν υπάρχει, το φτιάχνουμε
os.makedirs(remove_folder, exist_ok=True)

# Διαβάζουμε τη λίστα από το CSV
to_remove = pd.read_csv(csv_path, header=None)[0].str.strip().str.lower().tolist()

# Παίρνουμε όλα τα αρχεία fasta/fastq/asm
all_files = [f for f in os.listdir(seq_folder) 
             if f.lower().endswith((".fasta", ".fa", ".fas", ".fastq", ".fna"))]

removed = []
not_found = []

# Συγκρίνουμε και μετακινούμε
for f in all_files:
    name = f.lower()
    if any(name.startswith(rem) for rem in to_remove):
        shutil.move(os.path.join(seq_folder, f),
                    os.path.join(remove_folder, f))
        removed.append(f)
    else:
        pass

# Αποτελέσματα
print("=== Removed assemblies ===")
for f in removed:
    print(f)

print("\n=== Assemblies not found in folder ===")
for r in to_remove:
    if not any(r in f.lower() for f in all_files):
        print(r)

print("\nDONE!")



