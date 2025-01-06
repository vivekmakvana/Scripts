# Connect to Azure AD
Connect-AzureAD

# Get all guest users
$guestUsers = Get-AzureADUser -Filter "UserType eq 'Guest'"

# Create an array to store results
$results = @()

foreach ($user in $guestUsers) {
    $mfaStatus = Get-MsolUser -UserPrincipalName $user.UserPrincipalName | Select-Object StrongAuthenticationMethods

    # Add user information and MFA status to results
    $results += [PSCustomObject]@{
        DisplayName = $user.DisplayName
        Email = $user.UserPrincipalName
        MFAEnabled = if ($mfaStatus.StrongAuthenticationMethods.Count -gt 0) { "Enabled" } else { "Disabled" }
    }
}

# Export results to CSV
$results | Export-Csv -Path "C:\MECM\GuestUsers_MFAStatus.csv" -NoTypeInformation -Encoding UTF8

Write-Host "CSV file generated: C:\MECM\GuestUsers_MFAStatus.csv"
