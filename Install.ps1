#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Automates the installation of specific developer tools for Windows.
.DESCRIPTION
    Uses Winget to install Git, GitHub CLI, XAMPP 8.2, VS Code, NodeJS LTS, 
    MongoDB Server, and MongoDB Compass. Downloads and installs PHP Composer 
    via its official setup executable.
#>

Write-Host "Starting automated installation of developer tools..." -ForegroundColor Cyan

# Define tools and their exact Winget IDs in an ordered dictionary
$wingetTools = [ordered]@{
    "Git"                = "Git.Git"
    "GitHub CLI"         = "GitHub.cli"
    "XAMPP 8.2"          = "ApacheFriends.Xampp.8.2"
    "PostgreSQL 18"      = "PostgreSQL.PostgreSQL.18"
    "DBeaver"            = "DBeaver.DBeaver.Community"
    "Visual Studio Code" = "Microsoft.VisualStudioCode"
    "NodeJS LTS"         = "OpenJS.NodeJS.LTS"
    "MongoDB LTS"        = "MongoDB.Server"
    "MongoDB Compass"    = "MongoDB.Compass.Full"
}

# 1. Install tools via Winget
foreach ($tool in $wingetTools.GetEnumerator()) {
    Write-Host "`nInstalling $($tool.Name) via Winget..." -ForegroundColor Yellow
    
    # --exact ensures it matches the exact ID
    # --silent hides the installer GUI where possible
    # --accept-agreements bypasses interactive prompts
    $arguments = "install --id ""$($tool.Value)"" --exact --silent --accept-package-agreements --accept-source-agreements"
    
    $process = Start-Process -FilePath "winget" -ArgumentList $arguments -Wait -NoNewWindow -PassThru
    
    # Note: Winget may return non-zero exit codes if a package is already installed or requires a reboot.
    if ($process.ExitCode -eq 0) {
        Write-Host "$($tool.Name) installed successfully." -ForegroundColor Green
    } else {
        Write-Host "Winget finished $($tool.Name) with exit code $($process.ExitCode)." -ForegroundColor DarkGray
    }
}

# 2. Install Composer (Fallback to official installer)
Write-Host "`nInstalling Composer..." -ForegroundColor Yellow
$composerUrl = "https://getcomposer.org/Composer-Setup.exe"
$composerPath = "$env:TEMP\Composer-Setup.exe"

try {
    # UseBasicParsing is required in PS 5.1 if IE engine is not initialized
    Invoke-WebRequest -Uri $composerUrl -OutFile $composerPath -UseBasicParsing
    
    # Run the Composer installer silently for all users
    $composerArgs = "/VERYSILENT /ALLUSERS"
    $process = Start-Process -FilePath $composerPath -ArgumentList $composerArgs -Wait -NoNewWindow -PassThru
    
    if ($process.ExitCode -eq 0) {
        Write-Host "Composer installed successfully." -ForegroundColor Green
    } else {
        Write-Host "Composer installer exited with code $($process.ExitCode)." -ForegroundColor Red
    }
} catch {
    Write-Host "Failed to download or install Composer: $_" -ForegroundColor Red
} finally {
    # Clean up the installer file
    if (Test-Path $composerPath) {
        Remove-Item -Path $composerPath -Force
    }
}

Write-Host "`nDeployment tasks finished! Please restart your terminal to ensure all new environment variables (like PATH) are loaded correctly." -ForegroundColor Cyan
