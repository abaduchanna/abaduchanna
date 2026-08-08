@echo off
REM ==========================================================================
REM  GFH/VidaPay Bot — Build All EXEs (Overwrite Existing)
REM  Developed by Abad Umair Channa
REM
REM  This script:
REM    1. Pulls latest code from GitHub for all 9 repos
REM    2. Builds every .spec file with PyInstaller (clean build)
REM       — build/ and dist/ go to Downloads\GitHub\, NOT the source repo
REM    3. Moves the .exe files to Downloads\GitHub\ (overwrites existing)
REM    4. Cleans up the build/ and dist/ folders afterwards
REM
REM  SOURCE: C:\Users\AbadUmairChanna\OneDrive - Verge Mobile\Documents\GitHub\
REM  OUTPUT: C:\Users\AbadUmairChanna\Downloads\GitHub\
REM
REM  USAGE:
REM    Save as: build_all_exes.bat
REM    Double-click to run. Re-run anytime to rebuild + overwrite.
REM ==========================================================================

setlocal enabledelayedexpansion
title Build All GFH/VidaPay EXEs

set "SRC_BASE=C:\Users\AbadUmairChanna\OneDrive - Verge Mobile\Documents\GitHub"
set "OUT_BASE=C:\Users\AbadUmairChanna\Downloads\GitHub"
set "BUILD_DIR=%OUT_BASE%\build"
set "DIST_DIR=%OUT_BASE%\dist"

echo.
echo  ============================================================
echo   Build All GFH/VidaPay EXEs
echo  ============================================================
echo.
echo  Source:  %SRC_BASE%
echo  Output:  %OUT_BASE%
echo  Build:   %BUILD_DIR%
echo  Dist:    %DIST_DIR%
echo.

REM ── Step 0: Create output + build + dist folders ──
if not exist "%OUT_BASE%" mkdir "%OUT_BASE%"
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"
echo  Folders ready.
echo.

REM ── Step 1: Verify Python + PyInstaller ──
echo  Step 1: Checking prerequisites...
python --version >nul 2>&1
if errorlevel 1 (
    echo    ERROR: Python not found in PATH. Install Python 3.11+ first.
    pause
    exit /b 1
)
python -m PyInstaller --version >nul 2>&1
if errorlevel 1 (
    echo    Installing PyInstaller...
    python -m pip install --upgrade pyinstaller
)
echo    Python + PyInstaller OK
echo.

REM ── Step 2: Clean previous build/dist in Downloads\GitHub ──
echo  Step 2: Cleaning previous build/dist...
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%" 2>nul
if exist "%DIST_DIR%" rmdir /s /q "%DIST_DIR%" 2>nul
mkdir "%BUILD_DIR%" 2>nul
mkdir "%DIST_DIR%" 2>nul
echo    Cleaned.
echo.

REM ── Step 3: Define repos ──
set "REPOS="
set "REPOS=!REPOS! gfh-accessories-order-history-scraper"
set "REPOS=!REPOS! gfh-inventory-aging-processor"
set "REPOS=!REPOS! gfh-rebate-tools"
set "REPOS=!REPOS! gfh-ups-tracking-checker"
set "REPOS=!REPOS! gfh-xls-to-xlsx"
set "REPOS=!REPOS! vidapay-extractor"
set "REPOS=!REPOS! vidapay-gfh"
set "REPOS=!REPOS! vidapay-ordering"
set "REPOS=!REPOS! vidapay-transfer-bot"

set TOTAL_SUCCESS=0
set TOTAL_FAIL=0
set TOTAL_EXES=0

REM ── Step 4: Process each repo ──
for %%R in (!REPOS!) do (
    set "REPO=%%R"

    echo.
    echo  ============================================================
    echo   Repo: !REPO!
    echo  ============================================================

    set "REPO_PATH=%SRC_BASE%\!REPO!"

    REM Check if repo folder exists
    if not exist "!REPO_PATH!" (
        echo    ERROR: Repo folder not found: !REPO_PATH!
        echo    Skipping. Clone it first: git clone https://github.com/abaduchanna/!REPO!.git
        set /a TOTAL_FAIL+=1
    ) else (
        REM Pull latest
        echo    Pulling latest code...
        cd /d "!REPO_PATH!"
        git pull origin main >nul 2>&1
        if errorlevel 1 (
            echo    WARNING: git pull failed — building with current code
        ) else (
            echo    Pulled latest
        )

        REM Install dependencies
        if exist "requirements.txt" (
            echo    Installing dependencies...
            python -m pip install -r requirements.txt -q 2>nul
            python -m pip install pyinstaller -q 2>nul
        )

        REM Build every .spec file — output to Downloads\GitHub\build and \dist
        echo    Building .exe files ^(output to %DIST_DIR%^)...
        set REPO_SUCCESS=0
        set REPO_FAIL=0

        for %%S in (*.spec) do (
            python -m PyInstaller "%%S" --noconfirm --clean --workpath "%BUILD_DIR%" --distpath "%DIST_DIR%" >nul 2>&1
            if errorlevel 1 (
                echo      FAILED: %%S
                set /a REPO_FAIL+=1
            ) else (
                echo      BUILT:   %%S
                set /a REPO_SUCCESS+=1
            )
        )

        echo    Repo summary: !REPO_SUCCESS! built, !REPO_FAIL! failed
        set /a TOTAL_SUCCESS+=REPO_SUCCESS
        set /a TOTAL_FAIL+=REPO_FAIL
    )
)

REM ── Step 5: Count and list .exe files ──
cd /d "%DIST_DIR%"
echo.
echo  ============================================================
echo   Counting .exe files...
echo  ============================================================
for %%E in (*.exe) do set /a TOTAL_EXES+=1

REM ── Step 6: Move .exe files from dist\ to Downloads\GitHub\ (overwrite) ──
echo.
echo  Moving .exe files to %OUT_BASE% ...
for %%E in (*.exe) do (
    move /y "%%E" "%OUT_BASE%\" >nul 2>&1
    echo    Moved: %%~nxE
)

REM ── Step 7: Clean up build/ and dist/ folders ──
echo.
echo  Cleaning up build/dist folders...
cd /d "%OUT_BASE%"
if exist "build" rmdir /s /q "build" 2>nul
if exist "dist" rmdir /s /q "dist" 2>nul
echo    Cleaned.

echo.
echo  ============================================================
echo   BUILD COMPLETE
echo  ============================================================
echo.
echo  Successful builds:  !TOTAL_SUCCESS!
echo  Failed builds:      !TOTAL_FAIL!
echo  Total .exe files:   !TOTAL_EXES!
echo.
echo  .exe files in %OUT_BASE%:
echo  ------------------------------------------------------------
dir /b "*.exe" 2>nul
echo  ------------------------------------------------------------
echo.
echo  Source repos are clean — no build/ or dist/ folders left behind.
echo.
echo  You can now run any .exe from: %OUT_BASE%\
echo.
pause
endlocal
