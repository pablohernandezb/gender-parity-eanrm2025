import json

import json

def get_circunscriptions_by_state(json_file, target_election_type=20):
    """
    Parses a JSON file to extract unique circunscriptions for each state
    for a specific election type.

    Args:
        json_file (str): The path to the JSON file.
        target_election_type (int, optional): The election type to filter by. Defaults to 20.

    Returns:
        dict: A dictionary where keys are state codes and values are sets of unique circunscriptions.
    """

    with open(json_file, 'r') as f:
        data = json.load(f)['data']  # Load and extract the 'data' part

    state_circunscriptions = {}

    for item in data:
        if item['election_type_id'] == target_election_type:
            state_code = item['cod_state']
            circunscription = item['cod_circunscription']

            if state_code not in state_circunscriptions:
                state_circunscriptions[state_code] = set()  # Use a set to store unique values
            state_circunscriptions[state_code].add(circunscription)

    # Convert the sets back to lists for the final output (optional, but might be preferred)
    result = {state: sorted(list(circunscriptions)) for state, circunscriptions in state_circunscriptions.items()}
    return result

def main():
    # Usage
    json_file_path = "data/circunscription.json"  # Replace with your file path
    result = get_circunscriptions_by_state(json_file_path)

    for state, circunscriptions in result.items():
        print(f"State {state}: {circunscriptions}")

if __name__ == "__main__":
    main()