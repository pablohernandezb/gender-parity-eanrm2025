import csv

def collapse_election_data(input_file, output_file):
    """
    Colapsa las filas de datos de elecciones por tipo de elección y candidato,
    concatenando valores específicos y manejando la columna 'organization_ambit'.

    Args:
        input_file (str): La ruta al archivo de entrada (sample.txt).
        output_file (str): La ruta para el archivo de salida CSV.
    """
    data = []
    with open(input_file, 'r', encoding='utf-8') as infile:
        reader = csv.DictReader(infile)
        for row in reader:
            data.append(row)

    collapsed_data = {}
    columns_to_exclude = ['code_organization', 'organization_short_name', 'organization_description', 'organization_ambit']
    grouping_keys = ['election_type_description', 'document_id', 'first_name', 'second_name', 'first_last_name', 'second_last_name']
    columns_to_keep = [col for col in data[0].keys() if col not in columns_to_exclude]

    for row in data:
        group_key = tuple(row[key] for key in grouping_keys)
        if group_key not in collapsed_data:
            collapsed_data[group_key] = {col: row[col] for col in columns_to_keep}
            collapsed_data[group_key]['code_organization'] = [row['code_organization']]
            collapsed_data[group_key]['organization_short_name'] = [row['organization_short_name']]
            collapsed_data[group_key]['organization_description'] = [row['organization_description']]
            collapsed_data[group_key]['organization_ambit'] = [row['organization_ambit']]
        else:
            collapsed_data[group_key]['code_organization'].append(row['code_organization'])
            collapsed_data[group_key]['organization_short_name'].append(row['organization_short_name'])
            collapsed_data[group_key]['organization_description'].append(row['organization_description'])
            collapsed_data[group_key]['organization_ambit'].append(row['organization_ambit'])

    final_data = []
    for group, values in collapsed_data.items():
        new_row = {key: values[key] for key in columns_to_keep}
        new_row['code_organization'] = ', '.join(values['code_organization'])
        new_row['organization_short_name'] = ', '.join(values['organization_short_name'])
        new_row['organization_description'] = ', '.join(values['organization_description'])
        ambits = set(values['organization_ambit'])
        new_row['organization_ambit'] = ', '.join(ambits)
        final_data.append(new_row)

    # Ensure the order of columns in the output CSV
    output_columns = columns_to_keep + columns_to_exclude
    with open(output_file, 'w', newline='', encoding='utf-8') as outfile:
        writer = csv.DictWriter(outfile, fieldnames=output_columns)
        writer.writeheader()
        writer.writerows(final_data)

# Ejemplo de uso
input_file = 'dataset_eanr2025_postulaciones.csv'
output_file = 'collapsed_election_data.csv'
collapse_election_data(input_file, output_file)
print(f"Se ha creado el archivo '{output_file}' con los datos colapsados.")