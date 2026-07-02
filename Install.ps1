#Requires -RunAsAdministrator

<#
.SYNOPSIS
A minimal CLI tool to install standard development environments on Windows.
Handles Winget packages and custom direct-download installations.
#>

# Define the tools. Notice the 'Type' property to separate Winget from custom installers.
$tools = @(
    [PSCustomObject]@{ Name = "Git"; Id = "Git.Git"; Type = "Winget"; Selected = $true }
    [PSCustomObject]@{ Name = "GitHub CLI"; Id = "GitHub.cli"; Type = "Winget"; Selected = $true }
    [PSCustomObject]@{ Name = "XAMPP 8.2"; Id = "ApacheFriends.Xampp.8.2"; Type = "Winget"; Selected = $true }
    [PSCustomObject]@{ Name = "NodeJS LTS"; Id = "OpenJS.NodeJS.LTS"; Type = "Winget"; Selected = $true }
    [PSCustomObject]@{ Name = "Visual Studio Code"; Id = "Microsoft.VisualStudioCode"; Type = "Winget"; Selected = $true }
    [PSCustomObject]@{ Name = "MongoDB Server"; Id = "MongoDB.Server"; Type = "Winget"; Selected = $true }
    [PSCustomObject]@{ Name = "MongoDB Compass"; Id = "MongoDB.Compass.Community"; Type = "Winget"; Selected = $true }
    [PSCustomObject]@{ Name = "Composer"; Id = "Custom-Composer"; Type = "Custom"; Selected = $true }
    [PSCustomObject]@{ Name = "PostgreSQL 18"; Id = "PostgreSQL.PostgreSQL.18"; Type = "Winget"; Selected = $false }
    [PSCustomObject]@{ Name = "DBeaver"; Id = "DBeaver.DBeaver.Community"; Type = "Winget"; Selected = $false }
    [PSCustomObject]@{ Name = "Neovim"; Id = "Neovim.Neovim"; Type = "Winget"; Selected = $false }
)

function Show-Menu {
    Clear-Host
    Write-Host "tanaka - Common Web Development Tools Installer" -ForegroundColor Cyan
    Write-Host "========================="
    Write-Host "Type the numbers separated by commas (e.g., 8,9,10) to toggle your selections."
    Write-Host "Leave blank and press ENTER to proceed with the installation."
    Write-Host ""
    
    for ($i = 0; $i -lt $tools.Count; $i++) {
        $checkbox = if ($tools[$i].Selected) { "[X]" } else { "[ ]" }
        Write-Host ("{0,2}. {1} {2}" -f ($i + 1), $checkbox, $tools[$i].Name)
    }
    
    Write-Host "`nType 'Q' to quit."
}

# CLI Interaction Loop
$running = $true
while ($running) {
    Show-Menu
    $userInput = Read-Host "`nToggle selection(s) or press ENTER to start"
    
    if ([string]::IsNullOrWhiteSpace($userInput)) {
        $running = $false
    } elseif ($userInput.Trim() -match '^(q|Q)$') {
        Write-Host "`nInstallation aborted by user." -ForegroundColor Yellow
        exit
    } else {
        $selections = $userInput -split ',' | ForEach-Object { $_.Trim() }
        foreach ($sel in $selections) {
            if ([int]::TryParse($sel, [ref]$null)) {
                $index = [int]$sel - 1
                if ($index -ge 0 -and $index -lt $tools.Count) {
                    $tools[$index].Selected = -not $tools[$index].Selected
                }
            }
        }
    }
}

$selectedTools = $tools | Where-Object { $_.Selected }

if ($selectedTools.Count -eq 0) {
    Write-Host "`nNo tools selected for installation. Exiting." -ForegroundColor Yellow
    exit
}

Write-Host "`nStarting Installation Process..." -ForegroundColor Cyan
Write-Host "Please note: Some installers may still require manual interaction despite the silent flag.`n" -ForegroundColor DarkGray

# Execution Loop
foreach ($tool in $selectedTools) {
    Write-Host "Installing $($tool.Name)..." -ForegroundColor Yellow
    
    if ($tool.Type -eq "Winget") {
        # Standard Winget Execution
        $args = @("install", "--id", $tool.Id, "--exact", "--accept-package-agreements", "--accept-source-agreements", "--silent")
        try {
            $process = Start-Process -FilePath "winget" -ArgumentList $args -Wait -NoNewWindow -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Host "Successfully installed $($tool.Name)`n" -ForegroundColor Green
            } else {
                Write-Host "Installation for $($tool.Name) completed with non-zero exit code: $($process.ExitCode).`n" -ForegroundColor DarkYellow
            }
        } catch {
            Write-Host "Failed to execute Winget for $($tool.Name). Ensure Winget is installed.`n" -ForegroundColor Red
        }
    } 
    elseif ($tool.Name -eq "Composer") {
        # Custom Execution for Composer
        try {
            $composerUrl = "https://getcomposer.org/Composer-Setup.exe"
            $destPath = "$env:TEMP\Composer-Setup.exe"
            
            Write-Host "Downloading latest Composer installer..." -ForegroundColor DarkGray
            Invoke-WebRequest -Uri $composerUrl -OutFile $destPath -UseBasicParsing
            
            $compArgs = @("/VERYSILENT", "/ALLUSERS")
            $process = Start-Process -FilePath $destPath -ArgumentList $compArgs -Wait -NoNewWindow -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Host "Successfully installed Composer`n" -ForegroundColor Green
            } else {
                Write-Host "Installation for Composer completed with exit code: $($process.ExitCode).`n(Note: Composer requires PHP to be in your System PATH to install silently)`n" -ForegroundColor DarkYellow
            }
            Remove-Item $destPath -Force -ErrorAction SilentlyContinue
        } catch {
            Write-Host "Failed to download or install Composer.`n" -ForegroundColor Red
        }
    }
}

Write-Host "All selected tool installations have finished!" -ForegroundColor Cyan
