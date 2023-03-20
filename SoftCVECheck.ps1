# Get current user's desktop path
$desktop_path = [Environment]::GetFolderPath("Desktop")

# Get list of installed software with versions using 'Get-ItemProperty'
$software_list = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion |
    Sort-Object DisplayName

# Write software list to CSV file
$csv_path = Join-Path $desktop_path "installed_software.csv"
$software_list | Export-Csv -Path $csv_path -NoTypeInformation

# Compare software versions with NVD CVE database
$cve_report = ""
foreach ($software in $software_list) {
    $name = $software.DisplayName
    $version = $software.DisplayVersion

    # Build search URL
    $search_url = "https://nvd.nist.gov/vuln/search/results?form_type=Advanced&results_type=overview&search_type=all&cpe_vendor=cpe%3A%2F%3A$name&cpe_product=cpe%3A%2F%3A$name%3A$version"

    # Send search request
    $response = Invoke-WebRequest -Uri $search_url

    # Parse response for vulnerabilities
    $vuln_list = $response.ParsedHtml.GetElementsByClassName("vuln-title")

    # Add vulnerabilities to report
    if ($vuln_list.Count -gt 0) {
        $cve_report += "`n`nVulnerabilities for $name version $version:`n`n"
        foreach ($vuln in $vuln_list) {
            $cve_report += "- $($vuln.InnerText)`n"
        }
    }
}

# Write vulnerability report to text file
$txt_path = Join-Path $desktop_path "vulnerability_report.txt"
Set-Content -Path $txt_path -Value $cve_report
