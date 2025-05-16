import json
import asyncio
import aiohttp
from typing import List, Dict
import os

def get_circunscriptions_by_state(circunscription_json_file: str, party_position_json_file: str, target_election_type: int = 20) -> Dict[int, List[Dict[str, any]]]:
    """
    Parses circunscription and party position JSON files to extract unique circunscriptions
    for each state for a specific election type, including party codes.

    Args:
        circunscription_json_file (str): Path to the circunscription JSON file.
        party_position_json_file (str): Path to the party position JSON file.
        target_election_type (int, optional): The election type to filter by. Defaults to 20.

    Returns:
        dict: A dictionary where keys are state codes and values are lists of circunscription
              dictionaries, each including 'cod_circunscription' and 'party_codes'.
    """

    with open(circunscription_json_file, 'r') as f:
        circunscription_data = json.load(f)['data']

    with open(party_position_json_file, 'r') as f:
        party_position_data = json.load(f)['data']

    state_circunscriptions: Dict[int, List[Dict[str, any]]] = {}
    party_map: Dict[str, List[str]] = {}

    # Build a map of state -> list of party codes
    for party_item in party_position_data:
        state_code = party_item['cod_state']
        party_code = party_item['code_organization']
        if state_code not in party_map:
            party_map[state_code] = []
        if party_code not in party_map[state_code]:  # Ensure unique party codes per state
            party_map[state_code].append(party_code)

    for circunscription_item in circunscription_data:
        if circunscription_item['election_type_id'] == target_election_type:
            state_code = circunscription_item['cod_state']
            circunscription_code = circunscription_item['cod_circunscription']

            if state_code not in state_circunscriptions:
                state_circunscriptions[state_code] = []

            # Include party codes for each circunscription
            circunscription_entry = {
                'cod_circunscription': circunscription_code,
                'party_codes': party_map.get(state_code, [])  # Use get() to handle missing states
            }

            # Check for duplicates before appending
            if not any(d['cod_circunscription'] == circunscription_code for d in state_circunscriptions[state_code]):
                state_circunscriptions[state_code].append(circunscription_entry)

    return state_circunscriptions


async def fetch_data_for_state(session: aiohttp.ClientSession, url: str, state_code: int, circunscription_data: List[Dict[str, any]]) -> Dict:
    """
    Asynchronously fetches data for a single state, including iterating through each circunscription
    and its associated party codes.

    Args:
        session (aiohttp.ClientSession): The aiohttp client session.
        url (str): The URL to fetch data from.
        state_code (int): The state code.
        circunscription_data (list): A list of circunscription dictionaries, each with 'cod_circunscription'
                                     and 'party_codes'.

    Returns:
        dict or None: The combined JSON response as a dictionary, or None if there was an error.
    """
    all_state_data = {}
    for circunscription in circunscription_data:
        circunscription_code = circunscription['cod_circunscription']
        for party_code in circunscription['party_codes']:
            payload = {
                "eventId": 4,
                "stateCode": state_code,
                "municipalityCode": 1,
                "electionType": 20,
                "level": 4,
                "circunscriptionCodes": [circunscription_code],
                "codeOrganization": party_code,
            }

            headers = {
                "sec-ch-ua-platform": "\"Windows\"",
                "Referer": "https://doe.postulaciones.org.ve/",
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36",
                "Accept": "application/json, text/plain, */*",
                "sec-ch-ua": "\"Chromium\";v=\"136\", \"Google Chrome\";v=\"136\", \"Not.A/Brand\";v=\"99\"",
                "Content-Type": "application/json",
                "sec-ch-ua-mobile": "?0"
            }

            try:
                async with session.post(url, json=payload, headers=headers) as response:
                    if response.status == 200:
                        response_json = await response.json()
                        # Store data keyed by circunscription and party
                        key = f"{circunscription_code}_{party_code}"
                        all_state_data[key] = response_json
                    else:
                        print(f"Error fetching data for state {state_code}, circunscription {circunscription_code}, party {party_code}: Status code {response.status}")
            except Exception as e:
                print(f"An error occurred while fetching data for state {state_code}, circunscription {circunscription_code}, party {party_code}: {e}")
    return all_state_data if all_state_data else None


async def fetch_and_save_all_data_async(circunscription_json_file_path: str, party_position_json_file_path: str, url: str, output_filename: str = "all_states_output.json", output_dir: str = "output"):
    """
    Asynchronously fetches data for all states and saves it into a single JSON file.

    Args:
        circunscription_json_file_path (str): Path to the circunscription JSON file.
        party_position_json_file_path (str): Path to the party position JSON file.
        url (str): The URL to fetch data from.
        output_filename (str, optional): Name of the output JSON file.
        output_dir (str, optional): Directory to save the output.
    """

    state_circunscriptions = get_circunscriptions_by_state(circunscription_json_file_path, party_position_json_file_path)
    all_data = {}

    async with aiohttp.ClientSession() as session:
        tasks = []
        for state, circunscriptions in state_circunscriptions.items():
            print(f"Fetching data for state {state}...")
            tasks.append(fetch_data_for_state(session, url, state, circunscriptions))

        results = await asyncio.gather(*tasks)

        for state, result in zip(state_circunscriptions.keys(), results):
            if result:
                all_data[state] = result

    os.makedirs(output_dir, exist_ok=True)
    filepath = os.path.join(output_dir, output_filename)

    with open(filepath, 'w') as outfile:
        json.dump(all_data, outfile, indent=4)

    print(f"Data for all states saved to {filepath}")


# Usage (async)
circunscription_json_file_path = 'data/circunscription.json'
party_position_json_file_path = 'data/party_position.json'
url = "https://doe.postulaciones.org.ve:8085/api/event/4/fullview/region/"

try:
    asyncio.run(fetch_and_save_all_data_async(circunscription_json_file_path, party_position_json_file_path, url))
except ModuleNotFoundError as e:
    if e.name == 'aiohttp':
        print("Error: The 'aiohttp' library is required to run this code.")
        print("Please install it using: pip install aiohttp")
    else:
        raise e