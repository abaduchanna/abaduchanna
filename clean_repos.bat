@echo off
REM ==========================================================================
REM  GFH/VidaPay Bot — Clean build/ and dist/ from Source Repos
REM  Developed by Abad Umair Channa
REM
REM  This script deletes the build/ and dist/ folders (and __pycache__)
REM  from every repo in your GitHub source folder, keeping the repos clean.
REM
REM  SOURCE: C:\Users\AbadUmairChanna\OneDrive - Verge Mobile\Documents\GitHub\
REM
REM  USAGE:
REM    Save as: clean_repos.bat
REM    Double-click to run. Safe to re-run anytime.
REM
REM  WHAT IT DELETES (per repo):
REM    - build\         (PyInstaller build artifacts)
REM    - dist\          (PyInstaller output)
REM    - __pycache__\   (Python bytecode cache)
REM    - *.pyc          (compiled Python files)
REM    - *.log          (build logs)
REM
REM  It does NOT delete source code, .py files, .spec files, .ico, .png,
REM  or any other project files.
REM ==========================================================================

setlocal enabledelayedexpansion
title Clean build/ and dist/ from Source Repos

set "SRC_BASE=C:\Users\AbadUmairChanna\OneDrive - Verge Mobile\Documents\GitHub"

echo.
echo  ============================================================
echo   Clean build/ and dist/ from Source Repos
echo  ============================================================
echo.
echo  Source: %SRC_BASE%
echo.
echo  This will delete from each repo:
echo    - build\
echo    - dist\
echo    - __pycache__\
echo    - *.pyc files
echo    - *.log files
echo.
echo  Source code ^(.py, .spec, .ico, .png, etc.^) is NOT touched.
echo.
pause

REM ── Verify source folder exists ──
if not exist "%SRC_BASE%" (
    echo.
    echo  ERROR: Source folder not found:
    echo    %SRC_BASE%
    echo.
    echo  Please verify the path and try again.
    pause
    exit /b 1
)

set TOTAL_REPOS=0
set TOTAL_DIRS_DELETED=0
set TOTAL_FILES_DELETED=0

REM ── List of repos to clean ──
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

echo.
echo  Cleaning...
echo  ------------------------------------------------------------

for %%R in (!REPOS!) do (
    set "REPO=%%R"
    set "REPO_PATH=%SRC_BASE%\!REPO!"

    if not exist "!REPO_PATH!" (
        echo  [SKIP] !REPO! — folder not found
    ) else (
        echo.
        echo  [!REPO!]

        REM Delete build\ folder
        if exist "!REPO_PATH!\build" (
            rmdir /s /q "!REPO_PATH!\build" 2>nul
            if exist "!REPO_PATH!\build" (
                echo    build\  — FAILED to delete ^(may be in use^)
            ) else (
                echo    build\  — deleted
                set /a TOTAL_DIRS_DELETED+=1
            )
        ) else (
            echo    build\  — not present ^(already clean^)
        )

        REM Delete dist\ folder
        if exist "!REPO_PATH!\dist" (
            rmdir /s /q "!REPO_PATH!\dist" 2>nul
            if exist "!REPO_PATH!\dist" (
                echo    dist\   — FAILED to delete ^(may be in use^)
            ) else (
                echo    dist\   — deleted
                set /a TOTAL_DIRS_DELETED+=1
            )
        ) else (
            echo    dist\   — not present ^(already clean^)
        )

        REM Delete __pycache__\ folders (there may be multiple, nested)
        set PCACHE_COUNT=0
        for /d /r "!REPO_PATH!" %%D in (__pycache__) do (
            if exist "%%D" (
                rmdir /s /q "%%D" 2>nul
                set /a PCACHE_COUNT+=1
            )
        )
        if !PCACHE_COUNT! gtr 0 (
            echo    __pycache__\ — deleted !PCACHE_COUNT! folder^(s^)
            set /a TOTAL_DIRS_DELETED+=PCACHE_COUNT
        ) else (
            echo    __pycache__\ — not present
        )

        REM Delete *.pyc files
        set PYC_COUNT=0
        for /r "!REPO_PATH!" %%F in (*.pyc) do (
            del /q "%%F" 2>nul
            set /a PYC_COUNT+=1
        )
        if !PYC_COUNT! gtr 0 (
            echo    *.pyc   — deleted !PYC_COUNT! file^(s^)
            set /a TOTAL_FILES_DELETED+=PYC_COUNT
        ) else (
            echo    *.pyc   — not present
        )

        REM Delete *.log files (build logs, not important)
        set LOG_COUNT=0
        for /r "!REPO_PATH!" %%F in (*.log) do (
            del /q "%%F" 2>nul
            set /a LOG_COUNT+=1
        )
        if !LOG_COUNT! gtr 0 (
            echo    *.log   — deleted !LOG_COUNT! file^(s^)
            set /a TOTAL_FILES_DELETED+=LOG_COUNT
        )

        set /a TOTAL_REPOS+=1
    )
)

echo.
echo  ============================================================
echo   CLEANUP COMPLETE
echo  ============================================================
echo.
echo  Repos scanned:        !TOTAL_REPOS!
echo  Folders deleted:      !TOTAL_DIRS_DELETED!
echo  Files deleted:        !TOTAL_FILES_DELETED!
echo.
echo  All source repos are now clean.
echo  Source code ^(.py, .spec, .ico, .png^) is untouched.
echo.
pause
endlocal
