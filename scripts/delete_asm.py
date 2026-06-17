import pandas as pd
import os

# Φάκελος με τα .asm αρχεία
folder = r"C:\Users\kapos\OneDrive\Υπολογιστής\bash\assemblies"  # άλλαξε αν χρειάζεται

# CSV με τα αρχεία που πρέπει να φύγουν
to_remove = pd.read_csv(r"C:\Users\kapos\OneDrive\Υπολογιστής\bash\small_seq.csv", header=None)[0].str.strip().str.lower().tolist()

# Λίστα μόνο των .asm αρχείων
all_files = [f for f in os.listdir(folder) if f.lower().endswith(".asm")]

for f in all_files:
    f_lower = f.strip().lower()
    if f_lower in to_remove:
        os.remove(os.path.join(folder, f))
        print(f"delete: {f}")
    else:
        print(f"not delete : {f}")
