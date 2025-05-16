import csv
import os  # Import the os module for file path manipulation

def split_by_election_type(input_file):
    """
    Divide un archivo CSV en múltiples archivos CSV, donde cada archivo contiene
    las filas correspondientes a un único valor de 'election_type_id'.

    Args:
        input_file (str): La ruta al archivo CSV de entrada.
    """

    data = []
    with open(input_file, 'r', encoding='utf-8') as infile:
        reader = csv.DictReader(infile)
        for row in reader:
            data.append(row)

    election_type_ids = set(row['election_type_id'] for row in data)

    for election_id in election_type_ids:
        output_file = f'election_type_{election_id}.csv'
        filtered_data = [row for row in data if row['election_type_id'] == election_id]

        if filtered_data:  # Only create a file if there's data
            with open(output_file, 'w', newline='', encoding='utf-8') as outfile:
                writer = csv.DictWriter(outfile, fieldnames=data[0].keys())
                writer.writeheader()
                writer.writerows(filtered_data)
            print(f"Se ha creado el archivo '{output_file}' con {len(filtered_data)} filas.")
        else:
            print(f"No hay datos para election_type_id = {election_id}. No se creó el archivo '{output_file}'.")


# Ejemplo de uso
input_file = 'dataset_eanr2025_candidatos.csv'  # Replace with your file name
split_by_election_type(input_file)