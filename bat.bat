@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Fern V2 - GitHub Uploader

echo.
echo ==========================================
echo          FERN V2 GitHub Uploader
echo ==========================================
echo.

REM ==================================================
REM SETTINGS
REM ==================================================

set "REPO_URL=https://github.com/Bloxxersmc/FERN-V2.git"

REM ==================================================
REM USE THE FOLDER CONTAINING THIS BAT
REM ==================================================

cd /d "%~dp0"

echo [1/5] Checking Git...
where git >nul 2>&1

if errorlevel 1 (
    echo.
    echo ERROR: Git is not installed or not in PATH.
    pause
    exit /b 1
)

echo Git found.

echo.
echo [2/5] Checking GitHub CLI...
where gh >nul 2>&1

if errorlevel 1 (
    echo.
    echo ERROR: GitHub CLI is not installed or not in PATH.
    pause
    exit /b 1
)

echo GitHub CLI found.

echo.
echo [3/5] Checking GitHub login...

gh auth status >nul 2>&1

if errorlevel 1 (
    echo.
    echo You are not logged into GitHub.
    echo Starting GitHub login...
    echo.

    gh auth login

    if errorlevel 1 (
        echo.
        echo ERROR: GitHub login failed.
        pause
        exit /b 1
    )
)

echo GitHub login OK.

echo.
echo [4/5] Preparing repository...

REM ==================================================
REM INITIALIZE GIT IF NEEDED
REM ==================================================

if not exist ".git" (
    echo Initializing Git repository...
    git init

    if errorlevel 1 (
        echo.
        echo ERROR: git init failed.
        pause
        exit /b 1
    )
)

REM ==================================================
REM MAKE SURE WE USE MAIN
REM ==================================================

git branch -M main

REM ==================================================
REM SET THE CORRECT ORIGIN
REM ==================================================

echo.
echo Setting GitHub remote...

git remote get-url origin >nul 2>&1

if errorlevel 1 (
    echo No origin exists.
    git remote add origin "%REPO_URL%"
) else (
    echo Existing origin found.
    echo Updating origin...
    git remote set-url origin "%REPO_URL%"
)

if errorlevel 1 (
    echo.
    echo ERROR: Could not configure origin.
    pause
    exit /b 1
)

echo.
echo Remote:
git remote -v

REM ==================================================
REM ADD EVERYTHING
REM ==================================================

echo.
echo Adding EVERYTHING in this folder...

git add -A

if errorlevel 1 (
    echo.
    echo ERROR: git add failed.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo Git status:
echo ==========================================
git status
echo ==========================================

REM ==================================================
REM COMMIT IF THERE ARE CHANGES
REM ==================================================

echo.

git diff --cached --quiet

if errorlevel 1 (
    echo Changes detected.
    echo Creating commit...

    git commit -m "Fern V2 update"

    if errorlevel 1 (
        echo.
        echo ERROR: Commit failed.
        pause
        exit /b 1
    )

    echo Commit created.
) else (
    echo No new changes to commit.
)

REM ==================================================
REM PUSH EVERYTHING
REM ==================================================

echo.
echo [5/5] Pushing to GitHub...

echo.
echo Repository:
echo https://github.com/Bloxxersmc/FERN-V2
echo.

git push -u origin main

if errorlevel 1 (
    echo.
    echo ==========================================
    echo          FIRST PUSH ATTEMPT FAILED
    echo ==========================================
    echo.

    echo Attempting to synchronize with GitHub...
    echo.

    git pull --rebase origin main

    if errorlevel 1 (
        echo.
        echo ERROR: GitHub synchronization failed.
        echo.
        echo Your local files and commits are still safe.
        pause
        exit /b 1
    )

    echo.
    echo Synchronization successful.
    echo Retrying push...
    echo.

    git push -u origin main

    if errorlevel 1 (
        echo.
        echo ==========================================
        echo              PUSH FAILED
        echo ==========================================
        echo.
        echo Your local files and commits are still safe.
        pause
        exit /b 1
    )
)

echo.
echo ==========================================
echo              SUCCESS!
echo ==========================================
echo.
echo Fern V2 has been pushed successfully.
echo.
echo Repository:
echo https://github.com/Bloxxersmc/FERN-V2
echo.
echo ==========================================
echo.

pause