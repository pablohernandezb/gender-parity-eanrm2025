import json
import csv

def json_to_csv(json_file_path, csv_file_path, column_order):
    """
    Converts a JSON file to a CSV file, extracting data from the "data" elements,
    and uses a specified column order.

    Args:
        json_file_path (str): The path to the input JSON file.
        csv_file_path (str): The path to the output CSV file.
        column_order (list):  A list of column names in the desired order for the CSV.
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
    for item in data:
        if "data" in item and isinstance(item["data"], list):
            all_data.extend(item["data"])

    if not all_data:
        print("No 'data' elements found or 'data' is not a list in the JSON file.")
        return

    with open(csv_file_path, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)

        # Write the headers to the CSV file, using the provided column order
        writer.writerow(column_order)

        # Write the data rows, ensuring the order matches the headers
        for row in all_data:
            writer.writerow([row.get(key, None) for key in column_order])


def main():

# Example usage:
    json_file = 'election_type_id_20.json'  # Replace with your JSON file name
    csv_file = 'output_20.csv'       # Replace with your desired CSV file name

    column_order = [
        "id",
        "event_id",
        "cod_state",
        "state_description",
        "cod_municipality",
        "municipality_description",
        "cod_pair",
        "cod_contest",
        "cod_circunscription",
        "nacionality",
        "document_id",
        "gender",
        "first_last_name",
        "second_last_name",
        "first_name",
        "second_name",
        "cod_postulation",
        "election_type_id",
        "election_type_description",
        "ballot_name",
        "list_order",
        "code_organization",
        "organization_short_name",
        "organization_description",
        "organization_ambit",
        "nominal_order",
        "objection_id",
        "objection",
        "substitutions"
    ]

    json_to_csv(json_file, csv_file, column_order)
    print(f"Conversion complete. CSV file saved as {csv_file}")

if __name__ == "__main__":
    main()