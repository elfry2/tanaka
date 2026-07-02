#Requires -RunAsAdministrator

<#
.SYNOPSIS
A minimal CLI tool to install standard development environments on Windows via Winget.
#>

# Define the tools and their exact Winget IDs
$tools = @(
    [PSCustomObject]@{ Name = "Git"; Id = "Git.Git"; Selected = $true }
    [PSCustomObject]@{ Name = "GitHub CLI"; Id = "GitHub.cli"; Selected = $true }
    [PSCustomObject]@{ Name = "XAMPP 8.2"; Id = "ApacheFriends.XAMPP.8.2"; Selected = $true }
    [PSCustomObject]@{ Name = "Composer"; Id = "getcomposer.Composer"; Selected = $true }
    [PSCustomObject]@{ Name = "Visual Studio Code"; Id = "Microsoft.VisualStudioCode"; Selected = $true }
    [PSCustomObject]@{ Name = "NodeJS LTS"; Id = "OpenJS.NodeJS.LTS"; Selected = $true }
    [PSCustomObject]@{ Name = "MongoDB LTS"; Id = "MongoDB.Server"; Selected = $true }
    [PSCustomObject]@{ Name = "MongoDB Compass"; Id = "MongoDB.Compass.Community"; Selected = $true }
    [PSCustomObject]@{ Name = "PostgreSQL 18"; Id = "PostgreSQL.PostgreSQL.18"; Selected = $false }
    [PSCustomObject]@{ Name = "DBeaver"; Id = "DBeaver.DBeaver.Community"; Selected = $false }
    [PSCustomObject]@{ Name = "Neovim"; Id = "Neovim.Neovim"; Selected = $false }
)

function Show-Menu {
    Clear-Host
    Write-Host "tanaka - Common Web Development Tools Installer" -ForegroundColor Cyan
    Write-Host "========================="
    Write-Host "Type the numbers separated by commas (e.g., 1,3,5) to toggle your selections."
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
    Write-Host "Installing $($tool.Name) ($($tool.Id))..." -ForegroundColor Yellow
    
    # Using Start-Process to accurately capture the exit code from winget
    $args = @("install", "--id", $tool.Id, "--exact", "--accept-package-agreements", "--accept-source-agreements", "--silent")
    
    try {
        $process = Start-Process -FilePath "winget" -ArgumentList $args -Wait -NoNewWindow -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "Successfully installed $($tool.Name)`n" -ForegroundColor Green
        } else {
            Write-Host "Installation for $($tool.Name) completed with non-zero exit code: $($process.ExitCode).`n" -ForegroundColor DarkYellow
        }
    } catch {
        Write-Host "Failed to execute Winget for $($tool.Name). Ensure Winget is installed and added to your PATH.`n" -ForegroundColor Red
    }
}

Write-Host "All selected tool installations have finished!" -ForegroundColor Cyan
