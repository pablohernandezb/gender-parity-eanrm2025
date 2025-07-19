import json
import csv

def json_to_csv(json_file_path, csv_file_path, column_order):
    """
    Converts a JSON file to a CSV file, extracting data from the root list,
    and uses a specified column order.
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

    if not isinstance(data, list):
        print("JSON root is not a list.")
        return

    with open(csv_file_path, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(column_order)
        for row in data:
            substitutions = row.get('substitutions', [])
            substitutions_flag = 1 if substitutions and isinstance(substitutions, list) and len(substitutions) > 0 else 0
            output_row = [row.get(key, None) if key != 'substitutions' else substitutions_flag for key in column_order]
            writer.writerow(output_row)

def main():
    json_file = 'election_type_3.json'
    csv_file = 'election_type_3.csv'
    column_order = [
        "id", "event_id", "cod_state", "state_description", "cod_municipality",
        "municipality_description", "cod_pair", "cod_contest", "cod_circunscription",
        "nacionality", "document_id", "gender", "first_last_name", "second_last_name",
        "first_name", "second_name", "cod_postulation", "election_type_id",
        "election_type_description", "ballot_name", "list_order", "code_organization",
        "organization_short_name", "organization_description", "organization_ambit",
        "nominal_order", "objection_id", "objection", "substitutions"
    ]

    json_to_csv(json_file, csv_file, column_order)  # Use the modified function
    print(f"Conversion complete. CSV file saved as {csv_file}")

if __name__ == "__main__":
    main()