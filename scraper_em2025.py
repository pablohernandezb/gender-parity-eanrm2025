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

    for circ in circunscriptions:
        if circ.get("electionType", {}).get("id") != 3:
            continue
        circ_id = circ["cod_circunscription"]
        circ_name = circ["electionType"]["description"]
        state_id = circ["cod_state"]
        municipality_id = circ["cod_municipality"]
        code_organization = circ.get("code_organization")
        payload = {
            "eventId": 5,
            "stateCode": state_id,
            "municipalityCode": municipality_id,
            "electionType": 3,
            "level": 2,
            "circunscriptionCodes": [circ_id]
        }
        if code_organization is not None:
            payload["codeOrganization"] = code_organization
        print(f"Fetching candidates for circunscription {circ_name} ({circ_id})")
        data = scraper.fetch_page(url, payload)
        if data and "data" in data and data["data"]:
            for candidate in data["data"]:
                candidate["circunscription_id"] = circ_id
                candidate["circunscription_name"] = circ_name
                all_candidates.append(candidate)
        else:
            print(f"No candidate data found for circunscription {circ_name} ({circ_id})")

    scraper.save_to_json(all_candidates, "election_type_3.json")

if __name__ == "__main__":
    main()
