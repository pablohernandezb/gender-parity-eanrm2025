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
    # Load municipalities and parties
    with open("em2025/municipalities.json", encoding="utf-8") as f:
        municipalities = json.load(f)["data"]
    with open("em2025/partyPosition.json", encoding="utf-8") as f:
        parties = json.load(f)["data"]

    scraper = WebScraper()
    all_candidates = []
    url = "https://doe.postulaciones.org.ve:8085/api/event/5/fullview/region/"

    print(f"Loaded {len(parties)} parties. Sample: {parties[:2]}")

    for municipality in municipalities:
        state_id = municipality["cod_state"]
        municipality_id = municipality["cod_municipality"]
        municipality_name = municipality["description"]
        # Filter: party must be for electionType 16 and match state
        relevant_parties = [p for p in parties if p.get("cod_state") == state_id]
        print(f"Municipality {municipality_name} ({municipality_id}) has {len(relevant_parties)} relevant parties.")
        for party in relevant_parties:
            code_organization = party["code_organization"]
            party_name = party.get("organization_description", "")
            payload = {
                "eventId": 5,
                "stateCode": state_id,
                "municipalityCode": municipality_id,
                "electionType": 16,
                "level": 2,
                "circunscriptionCodes": [0],
                "codeOrganization": code_organization
            }
            print(f"Fetching candidates for municipality {municipality_name} ({municipality_id}), party {party_name} ({code_organization})")
            data = scraper.fetch_page(url, payload)
            if data and "data" in data and data["data"]:
                for candidate in data["data"]:
                    candidate["municipality_id"] = municipality_id
                    candidate["municipality_name"] = municipality_name
                    candidate["party_code_organization"] = code_organization
                    candidate["party_name"] = party_name
                    all_candidates.append(candidate)
            else:
                print(f"No candidate data found for municipality {municipality_name} ({municipality_id}), party {party_name} ({code_organization})")

    scraper.save_to_json(all_candidates, "election_type_16.json")

if __name__ == "__main__":
    main()
