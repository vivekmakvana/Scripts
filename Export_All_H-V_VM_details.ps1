# Run the following command on the remote server (192.168.X.X) to ensure that WinRM is enabled and configured properly:
Enable-PSRemoting -Force

# Add the Remote Server to TrustedHosts:
# On your local machine, run this command to add the remote server to the TrustedHosts list:
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "192.168.X.X" -Force
Restart-Service WinRM

# Define the IP addresses of the servers
$servers = @("192.168.X.X", "192.168.X.X")  # Replace with your server IPs

#Steps to Store Credentials Securely:
$credential = Get-Credential
$credential | Export-Clixml -Path "C:\Export\StoredCredential.xml"

# Load stored credentials
$credentialFile = "C:\Export\StoredCredential.xml"
if (Test-Path $credentialFile) {
    $credential = Import-Clixml -Path $credentialFile
} else {
    Write-Host "Credential file not found. Please create one using Export-Clixml."
    exit
}

# Define the output folder
$outputFolder = "C:\Export"

# Ensure the output folder exists
if (-not (Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder
}

# Initialize the CSV file
$outputFile = "$outputFolder\HyperV_VMs.csv"
if (Test-Path $outputFile) {
    Remove-Item $outputFile
}

# Loop through each server and collect Hyper-V VM information
foreach ($server in $servers) {
    Write-Host "Connecting to server $server..."
    
    try {
        # Invoke the command remotely
        Invoke-Command -ComputerName $server -Credential $credential -ScriptBlock {
            param ($serverIp)

            # Collect VM information
            $vms = Get-VM | Select-Object Name, State, CPUUsage, MemoryAssigned, Uptime, Status
            
            # Add the server IP to each VM object
            $vms | ForEach-Object {
                $_ | Add-Member -MemberType NoteProperty -Name HostServer -Value $serverIp -Force
                $_
            }
        } -ArgumentList $server | Export-Csv -Path $outputFile -NoTypeInformation -Append
    } catch {
        Write-Host "Failed to connect to $server. Error: $_" -ForegroundColor Red
    }
}

Write-Host "VM information collected and stored in $outputFile"
