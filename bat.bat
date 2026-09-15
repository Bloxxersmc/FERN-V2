@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Fern V2 - GitHub Uploader

echo.
echo ==========================================
echo          FERN V2 GitHub Uploader
echo ==========================================
echo.

set "REPO_NAME=FERN V2"
set "REPO_URL=https://github.com/Bloxxersmc/FERN-V2.git"

cd /d "%~dp0"

echo [1/6] Checking Git...
where git >nul 2>&1
if errorlevel 1 (
    echo ERROR: Git is not installed or not in PATH.
    pause
    exit /b 1
)
echo Git found.

echo.
echo [2/6] Checking GitHub CLI...
where gh >nul 2>&1
if errorlevel 1 (
    echo ERROR: GitHub CLI is not installed or not in PATH.
    pause
    exit /b 1
)
echo GitHub CLI found.

echo.
echo [3/6] Checking GitHub login...
gh auth status >nul 2>&1

if errorlevel 1 (
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
echo [4/6] Initializing repository...

if not exist ".git" (
    git init
)

git branch -M main

echo.
echo [5/6] Adding EVERYTHING...

git add -A

echo.
echo ==========================================
echo Current Git status:
echo ==========================================
git status

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
) else (
    echo No new changes to commit.
)

echo.
echo [6/6] Configuring GitHub remote...

git remote get-url origin >nul 2>&1

if errorlevel 1 (
    echo No existing origin found.
    git remote add origin "%REPO_URL%"
) else (
    echo Existing origin found.
    echo Updating origin...
    git remote set-url origin "%REPO_URL%"
)

if errorlevel 1 (
    echo.
    echo ERROR: Could not configure GitHub remote.
    pause
    exit /b 1
)

echo.
echo Checking GitHub repository...

gh repo view "%REPO_NAME%" >nul 2>&1

if errorlevel 1 (
    echo Repository does not exist.
    echo Creating "%REPO_NAME%"...

    gh repo create "%REPO_NAME%" --public

    if errorlevel 1 (
        echo.
        echo ERROR: Could not create GitHub repository.
        pause
        exit /b 1
    )

    echo Repository created.
) else (
    echo Repository already exists.
)

echo.
echo ==========================================
echo          Pushing Fern V2 to GitHub
echo ==========================================
echo.

git push -u origin main

if errorlevel 1 (
    echo.
    echo Push failed.
    echo Attempting to synchronize...

    git pull --rebase origin main

    if errorlevel 1 (
        echo.
        echo ERROR: Could not synchronize with GitHub.
        pause
        exit /b 1
    )

    echo.
    echo Retrying push...

    git push -u origin main

    if errorlevel 1 (
        echo.
        echo ERROR: Push still failed.
        pause
        exit /b 1
    )
)

echo.
echo ==========================================
echo              SUCCESS!
echo ==========================================
echo.
echo Everything in this folder has been
echo committed and pushed to:
echo.
echo https://github.com/Bloxxersmc/FERN-V2
echo.
pause