from curl_cffi import requests
import json

class WebScraper:
    def __init__(self):
        self.session = requests.Session(impersonate="chrome")
        self.headers = {
            "Accept": "application/json, text/plain, */*",
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/136.0.0.0 Safari/537.36",
            "Origin": "https://doe.postulaciones.org.ve",
            "Referer": "https://doe.postulaciones.org.ve/",
        }

    def fetch_page(self, url, payload):
        try:
            response = self.session.post(url, headers=self.headers, json=payload, impersonate="chrome")
            return response.json()
        except Exception as e:
            print(f"Error fetching {url} with payload {payload}: {str(e)}")
            return None

    def save_to_json(self, data, filename):
        with open(filename, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"Saved to {filename}")

def main():
    # Load circunscriptions and party positions
    with open("em2025/circunscriptions.json", encoding="utf-8") as f:
        circunscriptions = json.load(f)["data"]
    with open("em2025/partyPosition.json", encoding="utf-8") as f:
        party_positions = json.load(f)
    if isinstance(party_positions, dict) and "data" in party_positions:
        party_positions = party_positions["data"]

    scraper = WebScraper()
    all_candidates = []
    url = "https://doe.postulaciones.org.ve:8085/api/event/5/fullview/region/"

    for circ in circunscriptions:
        if circ.get("electionType", {}).get("id") != 15:
            continue
        circ_id = circ["cod_circunscription"]
        circ_name = circ["electionType"]["description"]
        state_id = circ["cod_state"]
        municipality_id = circ["cod_municipality"]
        # Filter parties relevant to this circunscription's state and municipality
        relevant_parties = [p for p in party_positions if isinstance(p, dict) and p.get("code_organization") and p.get("cod_state") == state_id and (p.get("cod_municipality") == municipality_id or p.get("cod_municipality") == 0)]
        for party in relevant_parties:
            code_organization = party["code_organization"]
            payload = {
                "eventId": 5,
                "stateCode": state_id,
                "municipalityCode": municipality_id,
                "electionType": 15,
                "level": 3,
                "circunscriptionCodes": [circ_id],
                "codeOrganization": code_organization
            }
            print(f"Fetching candidates for state {state_id}, municipality {municipality_id} and circunscription ({circ_id}), party {code_organization}")
            data = scraper.fetch_page(url, payload)
            if data and "data" in data and data["data"]:
                for candidate in data["data"]:
                    candidate["circunscription_id"] = circ_id
                    candidate["circunscription_name"] = circ_name
                    candidate["party_code_organization"] = code_organization
                    all_candidates.append(candidate)
            else:
                print(f"No candidate data found for circunscription {circ_name} ({circ_id}), party {code_organization}")

    scraper.save_to_json(all_candidates, "election_type_15.json")

if __name__ == "__main__":
    main()
