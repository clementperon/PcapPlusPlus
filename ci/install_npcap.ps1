# PowerShell script to install NPcap free version
# Updated to use interactive installation for newer NPcap versions

# Set NPcap version and file name
$NPCAP_FILE = "npcap-1.83.exe"

Write-Host "Using NPcap free version $NPCAP_FILE"

# Download NPcap free version
Write-Host "Downloading NPcap..."
try {
    Invoke-WebRequest -Uri "https://npcap.com/dist/$NPCAP_FILE" -OutFile $NPCAP_FILE -ErrorAction Stop
    Write-Host "Download completed successfully"
} catch {
    Write-Error "Failed to download NPcap: $_"
    exit 1
}

# Verify file was downloaded
if (-not (Test-Path $NPCAP_FILE)) {
    Write-Error "NPcap installer file not found after download"
    exit 1
}

Write-Host "Installing NPcap with interactive mode..."

# Launch installer
$process = Start-Process -FilePath ".\$NPCAP_FILE" -PassThru

# Wait for installer to show
Start-Sleep -Seconds 5

# Send keystrokes to navigate UI
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")   # Press 'Next'
Start-Sleep -Seconds 1
[System.Windows.Forms.SendKeys]::SendWait("{TAB}{SPACE}")  # Toggle option
Start-Sleep -Seconds 1
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")   # Press 'Install'

# Wait for installation to complete
Write-Host "Waiting for installation to complete..."
$process.WaitForExit()

if ($process.ExitCode -eq 0) {
    Write-Host "NPcap installation completed successfully"
} else {
    Write-Error "NPcap installation failed with exit code: $($process.ExitCode)"
    exit 1
}

# Download and extract NPcap SDK
Write-Host "Downloading NPcap SDK..."
try {
    $sdkParams = @{
        Uri = "https://npcap.com/dist/npcap-sdk-1.12.zip"
        OutFile = "npcap-sdk.zip"
        MaximumRetryCount = 5
        RetryIntervalSec = 2
        TimeoutSec = 120
        ErrorAction = "Stop"
    }
    Invoke-WebRequest @sdkParams
    Write-Host "SDK download completed"
} catch {
    Write-Error "Failed to download NPcap SDK: $_"
    exit 1
}

# Create SDK directory and extract
Write-Host "Extracting NPcap SDK..."
$sdkPath = "C:\Npcap-sdk"
if (-not (Test-Path $sdkPath)) {
    New-Item -ItemType Directory -Path $sdkPath -Force | Out-Null
}

try {
    Expand-Archive -Path "npcap-sdk.zip" -DestinationPath $sdkPath -Force
    Write-Host "NPcap SDK extracted successfully to $sdkPath"
} catch {
    Write-Error "Failed to extract NPcap SDK: $_"
    exit 1
}

# Clean up downloaded files
Remove-Item $NPCAP_FILE -ErrorAction SilentlyContinue
Remove-Item "npcap-sdk.zip" -ErrorAction SilentlyContinue

Write-Host "NPcap installation and SDK setup completed successfully!"
