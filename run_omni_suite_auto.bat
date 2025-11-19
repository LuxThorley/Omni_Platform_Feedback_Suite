@echo off
setlocal ENABLEDELAYEDEXPANSION

REM ================================================
REM Omni Platform Feedback Suite v2 - Auto Runner
REM - Extracts ZIP to default path
REM - Runs indexer, metrics, controller, web UI
REM - Opens default browser to local dashboard
REM ================================================

REM Root is the folder where this .bat lives
set "ROOT=%~dp0"
set "ZIP=%ROOT%omni_platform_feedback_suite_v2.zip"
set "TARGET=%ROOT%omni_platform_feedback_suite"

echo.
echo [OMNI] Root directory : "%ROOT%"
echo [OMNI] ZIP archive    : "%ZIP%"
echo [OMNI] Target folder  : "%TARGET%"
echo.

REM --- Check for ZIP existence ---
if not exist "%ZIP%" (
    echo [ERROR] Cannot find "%ZIP%".
    echo         Please make sure omni_platform_feedback_suite_v2.zip is in the same folder as this .bat.
    pause
    goto :eof
)

REM --- Extract ZIP if target folder doesn't exist ---
if not exist "%TARGET%" (
    echo [OMNI] Extracting suite from zip...
    powershell -NoLogo -NoProfile -Command "Expand-Archive -LiteralPath '%ZIP%' -DestinationPath '%TARGET%' -Force"
    if errorlevel 1 (
        echo [ERROR] Extraction failed.
        pause
        goto :eof
    )
) else (
    echo [OMNI] Target folder already exists, skipping extraction.
)

REM --- Change into suite directory ---
cd /d "%TARGET%"
if errorlevel 1 (
    echo [ERROR] Failed to change directory to "%TARGET%".
    pause
    goto :eof
)

REM --- Locate Python (prefer py -3, fallback to python) ---
set "PYTHON="

where py >nul 2>&1
if not errorlevel 1 (
    set "PYTHON=py -3"
)

if not defined PYTHON (
    where python >nul 2>&1
    if not errorlevel 1 (
        set "PYTHON=python"
    )
)

if not defined PYTHON (
    echo [ERROR] Python 3 not found in PATH.
    echo         Please install Python 3 or add it to your PATH.
    pause
    goto :eof
)

echo [OMNI] Using Python command: %PYTHON%
echo.

REM --- Step 1: Policy Indexer (PIFL) ---
echo [OMNI] Building policy index...
%PYTHON% controller\policy_indexer.py
if errorlevel 1 (
    echo [ERROR] Policy indexing failed.
    pause
    goto :eof
)

REM --- Step 2: Start Metrics Aggregator (background) ---
echo [OMNI] Starting metrics aggregator...
start "" %PYTHON% controller\metrics_aggregator.py

REM --- Step 3: Start Smart Controller (background) ---
echo [OMNI] Starting smart controller...
start "" %PYTHON% controller\smart_controller.py

REM --- Step 4: Start Web Dashboard (foreground window) ---
echo [OMNI] Starting web dashboard server...
start "" %PYTHON% ui\web_dashboard.py

REM --- Give the web server a moment to bind the port ---
echo [OMNI] Waiting for dashboard to come online...
timeout /t 5 /nobreak >nul

REM --- Step 5: Open default browser to the local dashboard ---
echo [OMNI] Opening dashboard in your default browser...
start "" http://127.0.0.1:8080/

echo.
echo [OMNI] Omni Platform Feedback Suite v2 is now running.
echo        - Metrics aggregator
echo        - Smart controller
echo        - Web dashboard at: http://127.0.0.1:8080/
echo.
echo        You may close this window or leave it open as a launcher log.
echo.
pause
endlocal
