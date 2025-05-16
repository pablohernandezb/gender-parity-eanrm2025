import pandas as pd
import glob
import os

def append_csv_files(input_folder, output_file):
    """
    Appends multiple CSV files located in the input_folder into a single CSV file.

    Args:
        input_folder (str): The path to the folder containing the CSV files.
        output_file (str): The path to the output CSV file where the combined data will be saved.
    """
    all_files = glob.glob(os.path.join(input_folder, "*.csv"))
    all_df = []

    if not all_files:
        print(f"No CSV files found in the folder: {input_folder}")
        return

    for f in all_files:
        try:
            df = pd.read_csv(f)
            all_df.append(df)
            print(f"Successfully read and added: {f}")
        except pd.errors.EmptyDataError:
            print(f"Warning: Skipping empty file: {f}")
        except FileNotFoundError:
            print(f"Error: File not found (shouldn't happen): {f}")
        except Exception as e:
            print(f"Error reading file {f}: {e}")

    if all_df:
        merged_df = pd.concat(all_df, ignore_index=True)
        try:
            merged_df.to_csv(output_file, index=False, encoding='utf-8')
            print(f"\nSuccessfully appended all CSV files to: {output_file}")
        except Exception as e:
            print(f"Error writing to output file {output_file}: {e}")
    else:
        print("\nNo dataframes were successfully created. Output file will not be created.")

if __name__ == "__main__":
    input_directory = input("Enter the path to the folder containing the CSV files: ")
    output_filename = input("Enter the desired name for the output CSV file (e.g., combined.csv): ")

    append_csv_files(input_directory, output_filename)