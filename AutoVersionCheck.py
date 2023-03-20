import csv
import subprocess

with open("software_versions.csv", "w", newline="") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["Software", "Version"])

    try:
        result = subprocess.check_output(['wmic', 'product', 'get', 'name,version', '/format:csv'])
        result = result.decode('utf-8').split('\r\r\n')
        for i in range(1, len(result)-1):
            item = result[i].split(',')
            writer.writerow([item[0], item[1]])
    except:
        pass
