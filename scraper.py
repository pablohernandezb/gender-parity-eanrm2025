from curl_cffi import requests
import json
import asyncio
import aiohttp


class WebScraper:
    def __init__(self):
        # Initialize with some common headers
        self.session = requests.Session(impersonate="chrome")
        self.headers = {
            "Accept": "application/json, text/plain, */*",
            "Accept-Language": "es-US,es;q=0.9,en-US;q=0.8,en;q=0.7,it-IT;q=0.6,it;q=0.5,es-419;q=0.4",
            "Connection": "keep-alive",
            # "If-None-Match": 'W/"64d-w/XWcI4nXvMD8VKTIvOsjhHwwss"',
            "Origin": "https://doe.postulaciones.org.ve",
            "Referer": "https://doe.postulaciones.org.ve/",
            "Sec-Fetch-Dest": "empty",
            "Sec-Fetch-Mode": "cors",
            "Sec-Fetch-Site": "same-site",
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36",
            "sec-ch-ua": '"Chromium";v="136", "Google Chrome";v="136", "Not.A/Brand";v="99"',
            "sec-ch-ua-mobile": "?0",
            "sec-ch-ua-platform": '"Windows"',
        }

    def fetch_page(self, url, payload=None):
        """
        Fetch a web page using curl_cffi
        """
        try:
            response = self.session.get(
                url, headers=self.headers, impersonate="chrome", json=payload
            )
            print(response.text)
            return response.json()  # Assuming the response is JSON
        except Exception as e:
            print(f"Error fetching {url}: {str(e)}")
            return None

    async def fetch_page_async(self, session, url, payload=None):
        """
        Fetch a web page asynchronously using aiohttp
        """
        try:
            async with session.get(url, headers=self.headers, json=payload) as response:
                return await response.json()
        except Exception as e:
            print(f"Error fetching {url}: {str(e)}")
            return None

    def save_to_json(self, data, filename="scraped_data.json"):
        """
        Save the scraped data to a JSON file
        """
        try:
            with open(filename, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=4, ensure_ascii=False)
            print(f"Data successfully saved to {filename}")
        except Exception as e:
            print(f"Error saving data to JSON: {str(e)}")


async def process_circunscriptions(
    url, circunscription_region_data, circunscription_data, party_position_data
):
    scraper = WebScraper()
    result = []

    async with aiohttp.ClientSession() as session:
        tasks = []

        parties_code = list(
            set([party["code_organization"] for party in party_position_data["data"]])
        )

        for election_type in list(
            set(
                [
                    election_type["election_type_id"]
                    for election_type in circunscription_region_data["data"]
                ]
            )
        ):
            for circunscription in [
                i for i in circunscription_data["data"] if i["election_type_id"] == election_type
            ]:
                for party_code in parties_code:
                    payload = {
                        "eventId": 4,
                        "stateCode": circunscription["cod_state"],
                        "municipalityCode": circunscription["cod_municipality"],
                        "electionType": election_type,
                        "level": [
                            i["electionType"]["level"]
                            for i in circunscription_region_data["data"]
                            if i["cod_circunscription"] == circunscription["cod_circunscription"]
                            and i["election_type_id"] == circunscription["election_type_id"]
                            and i["cod_state"] == circunscription["cod_state"]
                            and i["cod_municipality"] == circunscription["cod_municipality"]
                            and i["cod_parish"] == circunscription["cod_parish"]
                        ][0],
                        "circunscriptionCodes": [circunscription["cod_circunscription"]],
                        "codeOrganization": party_code,
                    }
                    print(payload)
                    task = scraper.fetch_page_async(session, url.format("fullview/region"), payload)
                    tasks.append(task)

        # Wait for all requests to complete
        responses = await asyncio.gather(*tasks)
        result.extend([r for r in responses if r is not None])

    return result


def main():
    # Example usage
    scraper = WebScraper()

    # Example URL (replace with your target website)
    url = "https://doe.postulaciones.org.ve:8085/api/event/4/{}/"

    # Fetch initial data synchronously
    # states_data = scraper.fetch_page(url.format("states"))
    # municipalities_data = scraper.fetch_page(url.format("municipalities"))
    # parishes_data = scraper.fetch_page(url.format("parishes"))
    party_position_data = scraper.fetch_page(url.format("partyPosition"))
    circunscription_data = scraper.fetch_page(url.format("circunscriptions"))
    circunscription_region_data = scraper.fetch_page(url.format("circunscriptions/region"))

    # Save initial data to JSON
    # scraper.save_to_json(states_data, filename="data/states_data.json")
    # scraper.save_to_json(municipalities_data, filename="data/municipalities_data.json")
    # scraper.save_to_json(parishes_data, filename="data/parishes_data.json")
    scraper.save_to_json(party_position_data, filename="data/party_position.json")
    scraper.save_to_json(circunscription_data, filename="data/circunscription.json")
    scraper.save_to_json(circunscription_region_data, filename="data/circunscription_region.json")

    # Process circunscriptions asynchronously
    result = asyncio.run(
        process_circunscriptions(
            url, circunscription_region_data, circunscription_data, party_position_data
        )
    )
    scraper.save_to_json(result, filename="data/result3.json")


if __name__ == "__main__":
    main()
