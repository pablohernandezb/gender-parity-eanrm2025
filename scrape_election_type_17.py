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
    # Load circunscriptions only
    with open("em2025/circunscriptions.json", encoding="utf-8") as f:
        circunscriptions = json.load(f)["data"]

    scraper = WebScraper()
    all_candidates = []
    url = "https://doe.postulaciones.org.ve:8085/api/event/5/fullview/region/"

    # Load parties
    with open("em2025/partyPosition.json", encoding="utf-8") as f:
        parties = json.load(f)["data"]

    # Exclusion list
    excluded_codes = set([
        269, 906, 513, 1089, 1090, 1092, 1094, 458, 931, 1091, 814, 1072, 1095, 460, 1066, 276, 1049, 878, 868, 1053, 1017, 236, 1068, 1, 2, 1050, 1051, 1096, 1048, 1062, 1093, 6, 514, 9, 219, 803, 1065, 632, 1057, 1031, 4888, 518, 1087, 4902, 290, 4909
    ])

    for circ in circunscriptions:
        if circ.get("election_type_id") != 17:
            continue
        circ_id = circ["cod_circunscription"]
        circ_name = circ["electionType"]["description"]
        state_id = circ["cod_state"]
        municipality_id = circ["cod_municipality"]
        # Find relevant parties for this circunscription (all except excluded)
        relevant_parties = [p for p in parties if p.get("code_organization") not in excluded_codes]
        for party in relevant_parties:
            code_organization = party["code_organization"]
            party_name = party.get("organization_description", "")
            payload = {
                "eventId": 5,
                "stateCode": state_id,
                "municipalityCode": municipality_id,
                "electionType": 17,
                "level": 2,
                "circunscriptionCodes": [circ_id],
                "codeOrganization": code_organization
            }
            print(f"Fetching candidates for circunscription {circ_name} ({circ_id}), party {party_name} ({code_organization})")
            data = scraper.fetch_page(url, payload)
            if data and "data" in data and data["data"]:
                for candidate in data["data"]:
                    candidate["circunscription_id"] = circ_id
                    candidate["circunscription_name"] = circ_name
                    candidate["party_code_organization"] = code_organization
                    candidate["party_name"] = party_name
                    all_candidates.append(candidate)
            else:
                print(f"No candidate data found for circunscription {circ_name} ({circ_id}), party {party_name} ({code_organization})")

    scraper.save_to_json(all_candidates, "election_type_17.json")

if __name__ == "__main__":
    main()
