# Written by Claude (https://claude.ai/share/b8ea580d-934a-42c8-acdb-e029856c1016).

#Requires -RunAsAdministrator

$tools = @(
    @{ Name = "Git";              Id = "Git.Git"                    },
    @{ Name = "GitHub CLI";       Id = "GitHub.cli"                 },
    @{ Name = "XAMPP 8.2";        Id = "ApacheFriends.Xampp.8.2"    },
    @{ Name = "Composer";         Id = "Composer.Composer"          },
    @{ Name = "Visual Studio Code"; Id = "Microsoft.VisualStudioCode" },
    @{ Name = "Node.js LTS";      Id = "OpenJS.NodeJS.LTS"          },
    @{ Name = "MongoDB LTS";      Id = "MongoDB.Server"             },
    @{ Name = "MongoDB Compass";  Id = "MongoDB.Compass.Full"       }
)

function Install-Tool {
    param (
        [string]$Name,
        [string]$Id
    )

    Write-Host "`nInstalling $Name..." -ForegroundColor Cyan

    $result = winget install --id $Id --silent --accept-package-agreements --accept-source-agreements 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "$Name installed successfully." -ForegroundColor Green
    } elseif ($LASTEXITCODE -eq -1978335189) {
        # 0x8A150077 — already installed
        Write-Host "$Name is already installed. Skipping." -ForegroundColor Yellow
    } else {
        Write-Host "Failed to install $Name (exit code: $LASTEXITCODE)." -ForegroundColor Red
        Write-Host $result
    }
}

# ── Header ────────────────────────────────────────────────────────────────────

Clear-Host
Write-Host "=======================================" -ForegroundColor Magenta
Write-Host "         tanaka — Dev Tool Installer   " -ForegroundColor Magenta
Write-Host "=======================================" -ForegroundColor Magenta
Write-Host "The following tools will be installed:"
$tools | ForEach-Object { Write-Host "  • $($_.Name)" }
Write-Host ""

$confirm = Read-Host "Proceed? (Y/n)"
if ($confirm -notin @("", "Y", "y")) {
    Write-Host "Aborted." -ForegroundColor Red
    exit 0
}

# ── Preflight: check WinGet ───────────────────────────────────────────────────

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "`nWinGet is not available. Please install App Installer from the Microsoft Store and try again." -ForegroundColor Red
    exit 1
}

# ── Install ───────────────────────────────────────────────────────────────────

$failed = @()

foreach ($tool in $tools) {
    Install-Tool -Name $tool.Name -Id $tool.Id
    if ($LASTEXITCODE -notin @(0, -1978335189)) {
        $failed += $tool.Name
    }
}

# ── Summary ───────────────────────────────────────────────────────────────────

Write-Host "`n=======================================" -ForegroundColor Magenta
Write-Host "              Summary                  " -ForegroundColor Magenta
Write-Host "=======================================" -ForegroundColor Magenta

if ($failed.Count -eq 0) {
    Write-Host "All tools installed successfully." -ForegroundColor Green
} else {
    Write-Host "The following tools failed to install:" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "  • $_" -ForegroundColor Red }
    Write-Host "`nTry re-running the script, or install them manually via:" -ForegroundColor Yellow
    Write-Host "  winget install --id <PackageId>" -ForegroundColor Yellow
}

Write-Host "`nDone. You may need to restart your terminal or PC for PATH changes to take effect." -ForegroundColor Cyan
