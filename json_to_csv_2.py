import json
import csv

def json_to_csv_nested(json_file_path, csv_file_path, column_order):
    """
    Converts a JSON file with a complex nested structure to a CSV file.
    The JSON has multiple layers of dictionaries with the actual data
    located in a list under the 'data' key.

    Args:
        json_file_path (str): Path to the input JSON file.
        csv_file_path (str): Path to the output CSV file.
        column_order (list): List of column names in the desired order for the CSV.
    """

    try:
        with open(json_file_path, 'r', encoding='utf-8') as json_file:
            data = json.load(json_file)
    except UnicodeDecodeError:
        with open(json_file_path, 'r', encoding='latin-1') as json_file:
            data = json.load(json_file)
    except Exception as e:
        print(f"Error loading JSON: {e}")
        return

    all_data = []

    # The JSON has a nested structure: dict -> dict -> dict -> list of dicts ('data')
    for top_level_key in data:  # e.g., "1", "2", etc.
        if isinstance(data[top_level_key], dict):
            for second_level_key in data[top_level_key]:  # e.g., "1_269", "1_1093", etc.
                if isinstance(data[top_level_key][second_level_key], dict) and \
                   "data" in data[top_level_key][second_level_key] and \
                   isinstance(data[top_level_key][second_level_key]["data"], list):
                    all_data.extend(data[top_level_key][second_level_key]["data"])

    if not all_data:
        print("No 'data' lists found in the expected structure within the JSON file.")
        return

    with open(csv_file_path, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(column_order)  # Write headers
        for row in all_data:
            writer.writerow([row.get(key, None) for key in column_order])


def main():
    json_file = 'election_type_id_7.json'  # Replace with your JSON file name
    csv_file = 'output_7.csv'  # Replace with your desired CSV file name

    column_order = [
        "id", "event_id", "cod_state", "state_description", "cod_municipality",
        "municipality_description", "cod_pair", "cod_contest", "cod_circunscription",
        "nacionality", "document_id", "gender", "first_last_name", "second_last_name",
        "first_name", "second_name", "cod_postulation", "election_type_id",
        "election_type_description", "ballot_name", "list_order", "code_organization",
        "organization_short_name", "organization_description", "organization_ambit",
        "nominal_order", "objection_id", "objection", "substitutions"
    ]

    json_to_csv_nested(json_file, csv_file, column_order)  # Use the modified function
    print(f"Conversion complete. CSV file saved as {csv_file}")

if __name__ == "__main__":
    main()