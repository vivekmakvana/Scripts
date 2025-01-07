# Install MSOnline Module if not already installed
# Install-Module MSOnline -Force

# Connect to Microsoft 365
Connect-MsolService

# Get all users
$users = Get-MsolUser -All

# Filter users with MFA disabled
$disabledMFAUsers = $users | Where-Object {
    $_.StrongAuthenticationRequirements.Count -eq 0 -and
    $_.StrongAuthenticationMethods.Count -eq 0
}

# Output results
if ($disabledMFAUsers) {
    $disabledMFAUsers | Select-Object DisplayName, UserPrincipalName, IsLicensed |
    Format-Table -AutoSize
    Write-Host "Found $($disabledMFAUsers.Count) users with MFA disabled."

    # Ensure the directory exists
    $outputFolder = "C:\mfareport\jan"
    if (!(Test-Path -Path $outputFolder)) {
        New-Item -ItemType Directory -Path $outputFolder -Force | Out-Null
    }

    # Export results to a CSV file
    $outputFile = "$outputFolder\DisabledMFAUsers.csv"
    $disabledMFAUsers | Select-Object DisplayName, UserPrincipalName, IsLicensed |
    Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

    Write-Host "Results exported to $outputFile"
} else {
    Write-Host "No users with MFA disabled found."
}
