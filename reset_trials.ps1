# ==========================================================================
#  VidaPay / GFH Trial Reset Script (PowerShell version)
#  Developed by Abad Umair Channa
#
#  Clears ALL trial enforcement data for every VidaPay bot variant.
#  Run this on the Windows machine where the bots are installed.
#
#  USAGE:
#    1. Save as:  reset_trials.ps1
#    2. Right-click -> "Run with PowerShell"
#       OR from PowerShell:  .\reset_trials.ps1
#    3. No admin rights required.
# ==========================================================================

$ErrorActionPreference = 'SilentlyContinue'

Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Cyan
Write-Host "   VidaPay / GFH Trial Reset (PowerShell)" -ForegroundColor Cyan
Write-Host "  ============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  This will clear trial data for:" -ForegroundColor Yellow
Write-Host "    - VidaPay Incentive Extractor (FULL / TRIAL / TRIAL_1Y)"
Write-Host "    - VidaPay Device Ordering (all 10 variants)"
Write-Host "    - VidaPay Inventory Transfer Bot"
Write-Host "    - GFH Inventory Audit"
Write-Host "    - GFH Accessories Ordering"
Write-Host ""
Write-Host "  NOTE: This also clears saved store lists and WhatsApp group" -ForegroundColor Yellow
Write-Host "  settings. Export them from the bot first if you want to keep them." -ForegroundColor Yellow
Write-Host ""
Read-Host "  Press Enter to continue, or Ctrl+C to cancel"

# --------------------------------------------------------------------------
# Step 1: Registry keys under HKCU\Software\VidaPay\
# --------------------------------------------------------------------------
Write-Host ""
Write-Host "  ---- Step 1: Registry keys (HKCU\Software\VidaPay\*) ----" -ForegroundColor Green

$regRoot = "HKCU:\Software\VidaPay"
if (Test-Path $regRoot) {
    $subkeys = Get-ChildItem $regRoot -ErrorAction SilentlyContinue
    foreach ($sk in $subkeys) {
        Remove-Item $sk.PSPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "    deleted  $($sk.Name)"
    }
    # Also remove the parent VidaPay key itself if empty
    Remove-Item $regRoot -Force -ErrorAction SilentlyContinue
    Write-Host "    deleted  $regRoot (parent)"
} else {
    Write-Host "    not found $regRoot  (already clean)"
}

# --------------------------------------------------------------------------
# Step 2: %LOCALAPPDATA%\VidaPay\  (hidden .vpsys + encrypted config.dat)
# --------------------------------------------------------------------------
Write-Host ""
Write-Host "  ---- Step 2: %LOCALAPPDATA%\VidaPay\ (trial markers + config) ----" -ForegroundColor Green

$vpDir = Join-Path $env:LOCALAPPDATA "VidaPay"
if (Test-Path $vpDir) {
    # Unhide everything first
    Get-ChildItem $vpDir -Recurse -Force | ForEach-Object {
        try { $_.Attributes = 'Normal' } catch {}
    }
    Remove-Item $vpDir -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path $vpDir) {
        Write-Host "    WARNING: could not fully remove $vpDir" -ForegroundColor Red
        Write-Host "    Close all VidaPay bots and re-run this script." -ForegroundColor Red
    } else {
        Write-Host "    removed   $vpDir"
    }
} else {
    Write-Host "    not found $vpDir  (already clean)"
}

# --------------------------------------------------------------------------
# Step 3: %APPDATA%\GFH Telecom\  (theme_config.json per app)
# --------------------------------------------------------------------------
Write-Host ""
Write-Host "  ---- Step 3: %APPDATA%\GFH Telecom\ (theme preferences) ----" -ForegroundColor Green

$gfhDir = Join-Path $env:APPDATA "GFH Telecom"
if (Test-Path $gfhDir) {
    Remove-Item $gfhDir -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path $gfhDir) {
        Write-Host "    WARNING: could not fully remove $gfhDir" -ForegroundColor Red
    } else {
        Write-Host "    removed   $gfhDir"
    }
} else {
    Write-Host "    not found $gfhDir  (already clean)"
}

# --------------------------------------------------------------------------
# Step 4: %APPDATA%\VidaPay_Transfer_Bot\  (transfer bot config + theme)
# --------------------------------------------------------------------------
Write-Host ""
Write-Host "  ---- Step 4: %APPDATA%\VidaPay_Transfer_Bot\ ----" -ForegroundColor Green

$tbDir = Join-Path $env:APPDATA "VidaPay_Transfer_Bot"
if (Test-Path $tbDir) {
    Remove-Item $tbDir -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path $tbDir) {
        Write-Host "    WARNING: could not fully remove $tbDir" -ForegroundColor Red
    } else {
        Write-Host "    removed   $tbDir"
    }
} else {
    Write-Host "    not found $tbDir  (already clean)"
}

# --------------------------------------------------------------------------
# Done
# --------------------------------------------------------------------------
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Cyan
Write-Host "   Done. All trial data cleared." -ForegroundColor Green
Write-Host "  ============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Next launch of any bot will start a fresh trial period."
Write-Host ""
Read-Host "  Press Enter to exit"
