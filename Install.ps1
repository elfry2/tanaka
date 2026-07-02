#Requires -RunAsAdministrator

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

while ($true) {
    Clear-Host
    Write-Host "tanaka - Common Web Development Tools Installer`n===============================================" -ForegroundColor Cyan
    Write-Host "Type numbers separated by commas to toggle. Press ENTER to install.`n"
    
    for ($i = 0; $i -lt $tools.Count; $i++) {
        $box = if ($tools[$i].Selected) { "[X]" } else { "[ ]" }
        Write-Host ("{0,2}. {1} {2}" -f ($i + 1), $box, $tools[$i].Name)
    }
    
    $input = (Read-Host "`nSelection (or 'q' to quit)").Trim()
    if ([string]::IsNullOrWhiteSpace($input)) { break }
    if ($input -eq 'q') { exit }
    
    foreach ($sel in ($input -split ',\s*')) {
        if ($sel -match '^\d+$') {
            $idx = [int]$sel - 1
            if ($idx -ge 0 -and $idx -lt $tools.Count) { $tools[$idx].Selected = -not $tools[$idx].Selected }
        }
    }
}

foreach ($tool in ($tools | Where-Object { $_.Selected })) {
    Write-Host "`nInstalling $($tool.Name)..." -ForegroundColor Yellow
    if ($tool.Type -eq "Winget") {
        Start-Process "winget" -ArgumentList "install --id $($tool.Id) --exact --accept-package-agreements --accept-source-agreements --silent" -Wait -NoNewWindow
    } else {
        $dir = "C:\ProgramData\Composer"
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Invoke-WebRequest -Uri "https://getcomposer.org/composer.phar" -OutFile "$dir\composer.phar" -UseBasicParsing
        Set-Content -Path "$dir\composer.bat" -Value '@php "%~dp0composer.phar" %*'
        $path = [Environment]::GetEnvironmentVariable("Path", "Machine")
        if ($path -notlike "*$dir*") { [Environment]::SetEnvironmentVariable("Path", "$path;$dir", "Machine") }
    }
}
Write-Host "`nDone! You'll need to restart the PC." -ForegroundColor Cyan
