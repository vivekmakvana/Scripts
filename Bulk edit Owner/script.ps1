# Import the necessary module
Import-Module AzureAD

# Connect to Azure AD
Connect-AzureAD

# Define the path to the CSV file
$csvPath = "C:\scripts\Bulk edit Owner\Groups_2.csv"
# Import the CSV file
$groups = Import-Csv -Path $csvPath

# Loop through each row in the CSV and add the owner to the security group
foreach ($group in $groups) {
    $GroupId = $group.GroupId
    $OwnerId = $group.OwnerId
    
    # Add the owner to the security group
    try {
        Add-AzureADGroupOwner -ObjectId $GroupId -RefObjectId $OwnerId
        Write-Host "Successfully added owner $OwnerId to group $GroupId"
    } catch {
        Write-Host "Failed to add owner $OwnerId to group $GroupId: $_"
    }
}

Write-Host "Script completed."
