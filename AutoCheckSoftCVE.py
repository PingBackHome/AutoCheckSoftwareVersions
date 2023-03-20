import csv
import os
import requests
import subprocess

# Get the path to the current user's desktop
desktop_path = os.path.join(os.path.expanduser("~"), "Desktop")

# Set the name of the output CSV file
csv_filename = "vulnerable_software.csv"

# Set the full path of the output CSV file
csv_filepath = os.path.join(desktop_path, csv_filename)

with open(csv_filepath, "w", newline="") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["Software", "Version", "CVE"])

    try:
        # Get a list of all installed software on the Windows machine
        result = subprocess.check_output(['wmic', 'product', 'get', 'name,version', '/format:csv'])
        result = result.decode('utf-8').split('\r\r\n')
        for i in range(1, len(result)-1):
            item = result[i].split(',')
            software_name = item[0]
            software_version = item[1]

            # Construct the API query URL to check if the software version is vulnerable
            query_url = f"https://services.nvd.nist.gov/rest/json/cves/1.0?cpeMatch=:::{software_name}::{software_version}"

            # Send a GET request to the NVD API to check if the software version is vulnerable
            response = requests.get(query_url)
            if response.status_code == 200:
                data = response.json()

                # If there are any CVEs associated with the software version, write them to the CSV file
                if "result" in data and "CVE_Items" in data["result"]:
                    cve_list = [x["cve"]["CVE_data_meta"]["ID"] for x in data["result"]["CVE_Items"]]
                    for cve in cve_list:
                        writer.writerow([software_name, software_version, cve])
    except:
        pass
