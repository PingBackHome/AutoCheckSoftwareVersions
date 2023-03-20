# Define variables
$csvPath = "$env:USERPROFILE\Desktop\InstalledSoftware.csv"
$reportPath = "$env:USERPROFILE\Desktop\SecurityReport.txt"
$cveUrl = "https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword="
$results = @()

# Get installed software
$software = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | 
            Select-Object DisplayName, DisplayVersion | 
            Sort-Object DisplayName

# Loop through software and check for CVEs
foreach ($app in $software) {
    $cve = $null
    if ($app.DisplayVersion) {
        $cveUrl = $cveUrl + "$($app.DisplayName) $app.DisplayVersion"
    } else {
        $cveUrl = $cveUrl + "$($app.DisplayName)"
    }
    $cvePage = Invoke-WebRequest -Uri $cveUrl -ErrorAction SilentlyContinue
    if ($cvePage.StatusCode -eq 200) {
        $cve = $cvePage.ParsedHtml.getElementsByTagName("a") | 
               Where-Object {$_.innerText -match "^CVE-\d{4}-\d+$"} | 
               Select-Object -First 1 -ExpandProperty innerText
    }
    $results += [PSCustomObject]@{
        "Software" = $app.DisplayName
        "Version" = $app.DisplayVersion
        "CVE" = $cve
    }
}

# Export results to CSV
$results | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

# Generate report
$report = "Security Report`r`n`r`n"
$report += "Installed Software:`r`n"
$report += "===================`r`n`r`n"
$results | Where-Object {$_.CVE} | 
    ForEach-Object {
        $report += "$($_.Software) $($_.Version) has a known CVE: $($_.CVE)`r`n"
    }
if ($report -eq "Security Report`r`n`r`nInstalled Software:`r`n===================`r`n`r`n") {
    $report += "No known vulnerabilities found.`r`n"
}

# Save report to file
Set-Content -Path $report
