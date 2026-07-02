#Requires -RunAsAdministrator

<#
.SYNOPSIS
A minimal CLI tool to manage (Install/Uninstall) standard development environments on Windows.
Handles Winget packages and custom configurations.
#>

# Define the baseline tools
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

# --- 1. Operation Mode Selection ---
Clear-Host
Write-Host "tanaka - Common Web Development Tools Manager" -ForegroundColor Cyan
Write-Host "============================================="
Write-Host "Choose an operation mode:"
Write-Host "1. Install"
Write-Host "2. Uninstall"
Write-Host "q. Quit"

$modeChoice = ""
while ($modeChoice -notmatch '^(1|2|q|Q)$') {
    $modeChoice = (Read-Host "`nSelect an option (1, 2, or q)").Trim()
}

if ($modeChoice -match '^(q|Q)$') {
    Write-Host "`nExiting tool manager." -ForegroundColor Yellow
    exit
}

# Adjust default state if user picked uninstallation
$isUninstall = $modeChoice -eq "2"
if ($isUninstall) {
    foreach ($tool in $tools) { $tool.Selected = $false }
}

# --- 2. Interactive Selection Menu ---
function Show-Selection-Menu {
    Clear-Host
    $titleSuffix = if ($isUninstall) { "UNINSTALLER MODE" } else { "INSTALLER MODE" }
    Write-Host "tanaka - Common Web Development Tools Manager [$titleSuffix]" -ForegroundColor Cyan
    Write-Host "========================================================="
    Write-Host "Type the numbers separated by commas (e.g., 1,3,5) to toggle selections."
    Write-Host "Leave blank and press ENTER to execute the operations."
    Write-Host ""
    
    for ($i = 0; $i -lt $tools.Count; $i++) {
        $checkbox = if ($tools[$i].Selected) { "[X]" } else { "[ ]" }
        Write-Host ("{0,2}. {1} {2}" -f ($i + 1), $checkbox, $tools[$i].Name)
    }
    
    Write-Host "`nType 'q' to abort."
}

$running = $true
while ($running) {
    Show-Selection-Menu
    $userInput = Read-Host "`nToggle selection(s) or press ENTER to start"
    
    if ([string]::IsNullOrWhiteSpace($userInput)) {
        $running = $false
    } elseif ($userInput.Trim() -match '^(q|Q)$') {
        Write-Host "`nOperation aborted by user." -ForegroundColor Yellow
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
    Write-Host "`nNo tools selected. Exiting." -ForegroundColor Yellow
    exit
}

# --- 3. Execution Engine ---
Write-Host "`nProcessing requested adjustments..." -ForegroundColor Cyan
$installDir = "C::\ProgramData\Composer" # Global custom track location

foreach ($tool in $selectedTools) {
    if (-not $isUninstall) {
        # ==================== INSTALLATION BLOCK ====================
        Write-Host "Installing $($tool.Name)..." -ForegroundColor Yellow
        
        if ($tool.Type -eq "Winget") {
            $args = @("install", "--id", $tool.Id, "--exact", "--accept-package-agreements", "--accept-source-agreements", "--silent")
            try {
                $process = Start-Process -FilePath "winget" -ArgumentList $args -Wait -NoNewWindow -PassThru
                if ($process.ExitCode -eq 0) { Write-Host "Successfully installed $($tool.Name)`n" -ForegroundColor Green }
                else { Write-Host "Failed installer code: $($process.ExitCode).`n" -ForegroundColor DarkYellow }
            } catch { Write-Host "Failed executing Winget for $($tool.Name).`n" -ForegroundColor Red }
        } 
        elseif ($tool.Name -eq "Composer") {
            try {
                $installDir = "C:\ProgramData\Composer"
                if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir -Force | Out-Null }
                
                Invoke-WebRequest -Uri "https://getcomposer.org/composer.phar" -OutFile "$installDir\composer.phar" -UseBasicParsing
                Set-Content -Path "$installDir\composer.bat" -Value '@php "%~dp0composer.phar" %*'
                
                $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
                if ($currentPath -notlike "*$installDir*") {
                    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$installDir", "Machine")
                    $env:Path += ";$installDir"
                }
                Write-Host "Successfully installed Composer wrapper framework.`n" -ForegroundColor Green
            } catch { Write-Host "Failed custom installation routine: $_`n" -ForegroundColor Red }
        }
    } 
    else {
        # ==================== UNINSTALLATION BLOCK ====================
        Write-Host "Uninstalling $($tool.Name)..." -ForegroundColor Orange
        
        if ($tool.Type -eq "Winget") {
            $args = @("uninstall", "--id", $tool.Id, "--exact", "--silent")
            try {
                $process = Start-Process -FilePath "winget" -ArgumentList $args -Wait -NoNewWindow -PassThru
                if ($process.ExitCode -eq 0) { Write-Host "Successfully removed $($tool.Name)`n" -ForegroundColor Green }
                else { Write-Host "Winget uninstaller exit code: $($process.ExitCode).`n" -ForegroundColor DarkYellow }
            } catch { Write-Host "Failed to call Winget uninstaller for $($tool.Name).`n" -ForegroundColor Red }
        } 
        elseif ($tool.Name -eq "Composer") {
            try {
                $installDir = "C:\ProgramData\Composer"
                if (Test-Path $installDir) {
                    Remove-Item $installDir -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Host "Deleted directory files..." -ForegroundColor DarkGray
                }
                
                # Dynamic environment variable array cleanup
                $rawEnv = [Environment]::GetEnvironmentVariable("Path", "Machine")
                $pathElements = $rawEnv -split ';' | Where-Object { $_ -ne $installDir -and -not [string]::IsNullOrWhiteSpace($_) }
                $cleanedPath = $pathElements -join ';'
                
                [Environment]::SetEnvironmentVariable("Path", $cleanedPath, "Machine")
                Write-Host "Cleaned Composer entries out of Machine Environment PATH.`n" -ForegroundColor Green
            } catch {
                Write-Host "Encountered issue dropping Composer clean hooks: $_`n" -ForegroundColor Red
            }
        }
    }
}

Write-Host "Task complete!" -ForegroundColor Cyan
