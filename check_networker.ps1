<#
.DESCRIPTION
Changeme
.EXAMPLE
.\check_networker.ps1 -server nwserver -user username -pwd password 
#>

# Parameters
Param(
  [string]$server,
  [string]$user,
  [string]$password,
  [string]$RestToolkitPath
)

# Import NWPSRestToolkit
import-module C:\PowerShellScripts\NWPSRestToolKit\NWPSRestToolKit.psd1

# States
$OK = 0
$WARNING = 1
$CRITICAL = 2
$UNKNOWN = 3

# Networker Credentials
$pwd = $password | ConvertTo-SecureString -asPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential($user,$pwd)

# Connect Networker server
$instance = Connect-NWServer -Credentials $Cred -NWIP $server -trustCert
if ($instance -eq $null) {
    Write-Host "UNKNOWN - Failed to connect to Networker server"
    exit $UNKNOWN
}

# Check last days backups
#$lastday = Get-Date -Day $((date -Format 'dd')-1) -Format 'yyyy-MM-dd*'
$lastday = $today = Get-Date -Format 'yyy-MM-dd*'

$failedjobs = Get-NWJobgroup | where { $_.endTime -Like $lastday -or $_.endTime -Like $today -and $_.type -Match 'workflow job' -and $_.completionStatus -NotMatch 'Succeeded'}

foreach ($job in $failedjobs) {
    $res = $job.command -match "-p (?<policy>.*) -w (?<workflow>.*) -L"
    $policy = $matches['policy']
    $wkflow = $matches['workflow']
    Write-Host "Policy:"$policy" Workflow: "$wkflow
}
