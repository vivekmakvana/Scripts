# Connect to Exchange Online
Connect-ExchangeOnline -Credential (Get-Credential)

# Get all distribution groups
$groups = Get-DistributionGroup -ResultSize Unlimited

# Create an array to store the results
$result = @()

# Iterate through each group
foreach ($group in $groups) {
    Write-Progress -Activity "Processing $($group.DisplayName)" -Status "$($groups.IndexOf($group) + 1) out of $($groups.Count) completed"

    # Get members of the group
    $members = Get-DistributionGroupMember -Identity $group.Name -ResultSize Unlimited

    # Add group and member details to the result array
    foreach ($member in $members) {
        $result += New-Object PSObject -Property @{
            GroupName = $group.DisplayName
            Member = $member.Name
            EmailAddress = $member.PrimarySMTPAddress
            RecipientType = $member.RecipientType
        }
    }
}

# Export the result to a CSV file
$result | Export-Csv -Path "C:\temp\DL_Members.csv" -NoTypeInformation