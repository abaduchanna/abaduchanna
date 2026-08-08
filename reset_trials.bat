@echo off
REM ==========================================================================
REM  VidaPay / GFH Trial Reset Script  (run on the bot machine, not the build server)
REM  Developed by Abad Umair Channa
REM
REM  Clears ALL trial enforcement data for every VidaPay bot variant:
REM    - Windows registry keys (HKCU\Software\VidaPay\*)
REM    - Hidden .vpsys trial marker files
REM    - Encrypted config.dat (store list, whatsapp group, etc.)
REM    - Theme preference files (GFH Telecom\<app>\theme_config.json)
REM
REM  After running this, every bot will behave as if launched for the
REM  first time (trial period restarts from full).
REM
REM  USAGE:
REM    1. Save as:  reset_trials.bat
REM    2. Double-click it, OR run from Command Prompt.
REM    3. No admin rights required (only touches HKCU and %LOCALAPPDATA%).
REM ==========================================================================

setlocal enabledelayedexpansion
title VidaPay / GFH Trial Reset

echo.
echo  ============================================================
echo   VidaPay / GFH Trial Reset
echo  ============================================================
echo.
echo  This will clear trial data for:
echo    - VidaPay Incentive Extractor (FULL / TRIAL / TRIAL_1Y)
echo    - VidaPay Device Ordering (all 10 variants)
echo    - VidaPay Inventory Transfer Bot
echo    - GFH Inventory Audit
echo    - GFH Accessories Ordering
echo.
echo  Storage locations to be cleared:
echo    1. Registry: HKCU\Software\VidaPay\*
echo    2. Files:    %%LOCALAPPDATA%%\VidaPay\*  (hidden .vpsys + config.dat)
echo    3. Theme:    %%APPDATA%%\GFH Telecom\*   (theme_config.json per app)
echo.
echo  NOTE: This also clears your saved store list and WhatsApp group
echo  settings (they are stored in the same config.dat). Export them
echo  from the bot first if you want to keep them.
echo.
pause

echo.
echo  ---- Step 1: Registry keys ----

for %%K in (
    "Software\VidaPay\IncentiveExtractor"
    "Software\VidaPay\DeviceOrdering"
    "Software\VidaPay\InventoryTransferBot"
    "Software\VidaPay\InventoryAudit"
    "Software\VidaPay\AccessoriesOrdering"
) do (
    reg query "HKCU\%%K" >nul 2>&1
    if !errorlevel! equ 0 (
        reg delete "HKCU\%%K" /f >nul 2>&1
        echo     deleted  HKCU\%%K
    ) else (
        echo     not found HKCU\%%K  (already clean)
    )
)

REM Also catch any future _VP_APP_KEY values under VidaPay\
reg query "HKCU\Software\VidaPay" >nul 2>&1
if !errorlevel! equ 0 (
    for /f "tokens=*" %%S in ('reg query "HKCU\Software\VidaPay" 2^>nul') do (
        reg delete "%%S" /f >nul 2>&1
        echo     deleted  %%S
    )
) else (
    echo     HKCU\Software\VidaPay  (already clean)
)

echo.
echo  ---- Step 2: %%LOCALAPPDATA%%\VidaPay\  (trial markers + encrypted config) ----

set "VP_DIR=%LOCALAPPDATA%\VidaPay"
if exist "%VP_DIR%" (
    attrib -h -s "%VP_DIR%\*.*" /s /d >nul 2>&1
    rmdir /s /q "%VP_DIR%" >nul 2>&1
    if exist "%VP_DIR%" (
        echo     WARNING: could not fully remove "%VP_DIR%"
        echo     Please close all VidaPay bots and re-run this script.
    ) else (
        echo     removed   "%VP_DIR%"
    )
) else (
    echo     not found "%VP_DIR%"  (already clean)
)

echo.
echo  ---- Step 3: %%APPDATA%%\GFH Telecom\  (theme preferences) ----

set "GFH_DIR=%APPDATA%\GFH Telecom"
if exist "%GFH_DIR%" (
    rmdir /s /q "%GFH_DIR%" >nul 2>&1
    if exist "%GFH_DIR%" (
        echo     WARNING: could not fully remove "%GFH_DIR%"
    ) else (
        echo     removed   "%GFH_DIR%"
    )
) else (
    echo     not found "%GFH_DIR%"  (already clean)
)

echo.
echo  ---- Step 4: VidaPay_Transfer_Bot APPDATA folder ----

set "TB_DIR=%APPDATA%\VidaPay_Transfer_Bot"
if exist "%TB_DIR%" (
    rmdir /s /q "%TB_DIR%" >nul 2>&1
    if exist "%TB_DIR%" (
        echo     WARNING: could not fully remove "%TB_DIR%"
    ) else (
        echo     removed   "%TB_DIR%"
    )
) else (
    echo     not found "%TB_DIR%"  (already clean)
)

echo.
echo  ============================================================
echo   Done. All trial data cleared.
echo  ============================================================
echo.
echo  Next launch of any bot will start a fresh trial period.
echo.
pause
endlocal
