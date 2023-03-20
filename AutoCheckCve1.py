import os
import csv
import requests
import xml.etree.ElementTree as ET

# Get current user's desktop path
desktop_path = os.path.join(os.path.join(os.environ['USERPROFILE']), 'Desktop')

# Get list of installed software with versions using 'wmic'
software_list = subprocess.check_output(['wmic', 'product', 'get', 'name,version']).decode('utf-8').split('\n')
software_list = [line.strip() for line in software_list if 'Name' not in line and line.strip()]

# Write software list to CSV file
csv_path = os.path.join(desktop_path, 'installed_software.csv')
with open(csv_path, mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['Software', 'Version'])
    for line in software_list:
        name, version = line.split('  ')
        writer.writerow([name.strip(), version.strip()])

# Compare software versions with NVD CVE database
cve_report = ''
for line in software_list:
    name, version = line.split('  ')
    name = name.strip()
    version = version.strip()

    # Build search URL
    search_url = f'https://nvd.nist.gov/vuln/search/results?form_type=Advanced&results_type=overview&search_type=all&cpe_vendor=cpe%3A%2F%3A{name}&cpe_product=cpe%3A%2F%3A{name}%3A{version}'

    # Send search request
    response = requests.get(search_url)

    # Parse response for vulnerabilities
    tree = ET.fromstring(response.content)
    vuln_list = tree.findall(".//div[@class='vuln-title']")

    # Add vulnerabilities to report
    if vuln_list:
        cve_report += f'\n\nVulnerabilities for {name} version {version}:\n\n'
        for vuln in vuln_list:
            cve_report += f'- {vuln.text}\n'

# Write vulnerability report to text file
txt_path = os.path.join(desktop_path, 'vulnerability_report.txt')
with open(txt_path, mode='w') as file:
    file.write(cve_report)
