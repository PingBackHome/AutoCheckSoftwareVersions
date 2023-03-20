import csv
import os
import subprocess

# Get the path to the current user's desktop
desktop_path = os.path.join(os.path.expanduser("~"), "Desktop")

# Set the name of the output CSV file
csv_filename = "software_versions.csv"

# Set the full path of the output CSV file
csv_filepath = os.path.join(desktop_path, csv_filename)

with open(csv_filepath, "w", newline="") as csvfile:
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
