#Requires -Version 5.1
<#
.SYNOPSIS
    Claude Power Setup — Windows PowerShell Installer
.DESCRIPTION
    Installs multi-agent orchestration, automation scripts, and self-improvement
    tools for Claude Code. Layers on top of ECC (Everything Claude Code).

    If bash is available (Git Bash, WSL, MSYS2), delegates to install.sh.
    Otherwise, performs native PowerShell file copies.
.PARAMETER DryRun
    Show what would be installed without writing files.
.PARAMETER Force
    Overwrite existing files instead of skipping.
.PARAMETER SkipShell
    Don't modify shell profile.
.PARAMETER SkipECC
    Don't check for ECC installation.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File install.ps1
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File install.ps1 -DryRun
#>
param(
    [switch]$DryRun,
    [switch]$Force,
    [switch]$SkipShell,
    [switch]$SkipECC,
    [switch]$Help
)

$Version = "1.0.0"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ClaudeHome = Join-Path $env:USERPROFILE ".claude"

if ($Help) {
    Get-Help $MyInvocation.MyCommand.Definition -Detailed
    exit 0
}

# ── Try to delegate to bash ────────────────────────────────────
$BashPaths = @(
    "C:\Program Files\Git\bin\bash.exe",
    "C:\Program Files (x86)\Git\bin\bash.exe",
    (Get-Command bash -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue)
) | Where-Object { $_ -and (Test-Path $_ -ErrorAction SilentlyContinue) }

if ($BashPaths.Count -gt 0) {
    $BashExe = $BashPaths[0]
    Write-Host "[i] Found bash at: $BashExe" -ForegroundColor Cyan
    Write-Host "[i] Delegating to install.sh..." -ForegroundColor Cyan

    $Args = @()
    if ($DryRun)    { $Args += "--dry-run" }
    if ($Force)     { $Args += "--force" }
    if ($SkipShell) { $Args += "--skip-shell" }
    if ($SkipECC)   { $Args += "--skip-ecc" }

    $InstallScript = Join-Path $ScriptDir "install.sh"
    & $BashExe $InstallScript @Args
    exit $LASTEXITCODE
}

# ── Native PowerShell fallback ─────────────────────────────────
Write-Host ""
Write-Host "  Claude Power Setup v$Version" -ForegroundColor White
Write-Host "  Multi-agent orchestration + self-improvement" -ForegroundColor Gray
Write-Host "  (PowerShell native mode — bash not found)" -ForegroundColor Yellow
Write-Host ""

if ($DryRun) {
    Write-Host "[!] DRY RUN - no files will be written" -ForegroundColor Yellow
    Write-Host ""
}

function Safe-Copy {
    param([string]$Source, [string]$Dest, [string]$Label)

    if ($DryRun) {
        if ((Test-Path $Dest) -and -not $Force) {
            Write-Host "[i] SKIP (exists): $Label" -ForegroundColor Cyan
        } else {
            Write-Host "[i] WOULD COPY: $Label -> $Dest" -ForegroundColor Cyan
        }
        return
    }

    $DestDir = Split-Path -Parent $Dest
    if (-not (Test-Path $DestDir)) {
        New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    }

    if ((Test-Path $Dest) -and -not $Force) {
        Write-Host "[i] Skip (exists): $Label" -ForegroundColor Cyan
        return
    }

    Copy-Item -Path $Source -Destination $Dest -Force
    Write-Host "[+] Installed: $Label" -ForegroundColor Green
}

# ── Install files ──────────────────────────────────────────────
Write-Host "Installing context profiles..." -ForegroundColor White
@("dev.md", "orchestrate.md", "review.md", "research.md") | ForEach-Object {
    Safe-Copy (Join-Path $ScriptDir "contexts\$_") (Join-Path $ClaudeHome "contexts\$_") "contexts\$_"
}

Write-Host "`nInstalling orchestration reference..." -ForegroundColor White
Safe-Copy (Join-Path $ScriptDir "reference\ORCHESTRATION-REFERENCE.md") `
          (Join-Path $ClaudeHome "contexts\ORCHESTRATION-REFERENCE.md") `
          "reference\ORCHESTRATION-REFERENCE.md"

Write-Host "`nInstalling automation scripts..." -ForegroundColor White
Get-ChildItem (Join-Path $ScriptDir "bin\*.sh") | ForEach-Object {
    Safe-Copy $_.FullName (Join-Path $ClaudeHome "bin\$($_.Name)") "bin\$($_.Name)"
}

Write-Host "`nInstalling learned instincts..." -ForegroundColor White
$InstinctDir = Join-Path $ClaudeHome "homunculus\instincts\personal"
if (-not $DryRun) {
    @(
        $InstinctDir,
        (Join-Path $ClaudeHome "homunculus\instincts\inherited"),
        (Join-Path $ClaudeHome "homunculus\evolved\agents"),
        (Join-Path $ClaudeHome "homunculus\evolved\skills"),
        (Join-Path $ClaudeHome "homunculus\evolved\commands"),
        (Join-Path $ClaudeHome "session-data"),
        (Join-Path $ClaudeHome "plans")
    ) | ForEach-Object {
        if (-not (Test-Path $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
    }
}
Get-ChildItem (Join-Path $ScriptDir "instincts\*.md") | ForEach-Object {
    Safe-Copy $_.FullName (Join-Path $InstinctDir $_.Name) "instincts\$($_.Name)"
}

# ── Merge env settings ────────────────────────────────────────
Write-Host "`nConfiguring settings.json..." -ForegroundColor White
$SettingsFile = Join-Path $ClaudeHome "settings.json"
$EnvFile = Join-Path $ScriptDir "config\env-settings.json"

if (-not $DryRun -and (Test-Path $SettingsFile) -and (Test-Path $EnvFile)) {
    try {
        $Settings = Get-Content $SettingsFile -Raw | ConvertFrom-Json
        $NewEnv = Get-Content $EnvFile -Raw | ConvertFrom-Json

        if (-not $Settings.env) {
            $Settings | Add-Member -Type NoteProperty -Name "env" -Value ([PSCustomObject]@{})
        }

        $NewEnv.PSObject.Properties | ForEach-Object {
            if (-not $Settings.env.PSObject.Properties[$_.Name]) {
                $Settings.env | Add-Member -Type NoteProperty -Name $_.Name -Value $_.Value
                Write-Host "[+] Added env: $($_.Name)=$($_.Value)" -ForegroundColor Green
            } else {
                Write-Host "[i] Skip env (exists): $($_.Name)" -ForegroundColor Cyan
            }
        }

        $Settings | ConvertTo-Json -Depth 10 | Set-Content $SettingsFile -Encoding UTF8
    } catch {
        Write-Host "[!] Could not merge env settings: $_" -ForegroundColor Yellow
    }
} elseif ($DryRun) {
    Write-Host "[i] WOULD MERGE: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS, ECC_HOOK_PROFILE, CLAUDE_CODE_ENABLE_COST_TRACKING" -ForegroundColor Cyan
}

# ── Summary ───────────────────────────────────────────────────
Write-Host ""
Write-Host "  Installation Complete" -ForegroundColor Green
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host "    1. Open Git Bash and run: source ~/.claude/bin/claude-aliases.sh"
Write-Host "    2. Open a project and run: claude"
Write-Host "    3. Try: 'Please use a team of specialists for this'"
Write-Host ""
Write-Host "  Reference: ~/.claude/contexts/ORCHESTRATION-REFERENCE.md"
Write-Host ""
