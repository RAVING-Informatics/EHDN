import pandas as pd
from collections import Counter
import os
import sys

# Step 1: Read Multiple TSV Files
# Assume 'sample_dir' contains the path to your directory of TSV files
sample_dir = str(sys.argv[1])
file_names = [f for f in os.listdir(sample_dir) if f.endswith('.tsv')]
dfs = [pd.read_csv(f"{sample_dir}/{file_name}", sep='\t') for file_name in file_names]

# Step 2: Aggregate Counts
# Count the occurrences of each value in the specified column across all DataFrames
agg_counts = Counter()
for df in dfs:
    agg_counts.update(df['gene'])  # Replace 'Value' with your specific column name if different

# Step 3: Add Counts to DataFrames
# Add a new column to each DataFrame with the aggregated counts
for df in dfs:
    df['gene_count'] = df['gene'].map(agg_counts)  # 'Value_Count' will be the new column

# Step 4: Save Modified TSV Files
# Save each modified DataFrame back to a TSV file
for df, file_name in zip(dfs, file_names):
    df.to_csv(f"{sample_dir}/{file_name}", sep='\t', index=False)