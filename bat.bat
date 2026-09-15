@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Fern V2 - GitHub Uploader

echo.
echo ==========================================
echo          FERN V2 GitHub Uploader
echo ==========================================
echo.

set "REPO_NAME=FERN V2"

cd /d "%~dp0"

echo [1/6] Checking Git...
where git >nul 2>&1
if errorlevel 1 (
    echo ERROR: Git is not installed or not in PATH.
    echo.
    pause
    exit /b 1
)

echo Git found.

echo.
echo [2/6] Checking GitHub CLI...
where gh >nul 2>&1
if errorlevel 1 (
    echo ERROR: GitHub CLI ^(gh^) is not installed or not in PATH.
    echo.
    echo Install GitHub CLI, then run this file again.
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

if not exist ".gitignore" (
    echo node_modules/ > ".gitignore"
    echo .vercel/ >> ".gitignore"
    echo .env >> ".gitignore"
    echo .env.* >> ".gitignore"
    echo !.env.example >> ".gitignore"
)

echo.
echo [5/6] Adding EVERYTHING...

git add -A

echo.
echo ==========================================
echo Current Git status:
echo ==========================================
git status

echo.
set "COMMIT_MSG="
set /p "COMMIT_MSG=Commit message [Fern V2 update]: "

if not defined COMMIT_MSG (
    set "COMMIT_MSG=Fern V2 update"
)

echo.
echo Creating commit...

git diff --cached --quiet

if errorlevel 1 (
    git commit -m "%COMMIT_MSG%"

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
echo [6/6] Checking GitHub repository...

gh repo view "%REPO_NAME%" >nul 2>&1

if errorlevel 1 (
    echo Repository does not exist.
    echo Creating "%REPO_NAME%"...

    gh repo create "%REPO_NAME%" --public --source=. --remote=origin

    if errorlevel 1 (
        echo.
        echo ERROR: Could not create the GitHub repository.
        pause
        exit /b 1
    )
) else (
    echo Repository already exists.

    git remote get-url origin >nul 2>&1

    if errorlevel 1 (
        for /f "delims=" %%U in (
            'gh repo view "%REPO_NAME%" --json url --jq ".url"'
        ) do (
            set "REPO_URL=%%U"
        )

        git remote add origin "!REPO_URL!.git"
    )
)

echo.
echo ==========================================
echo Pushing Fern V2...
echo ==========================================
echo.

git push -u origin main

if errorlevel 1 (
    echo.
    echo ==========================================
    echo PUSH FAILED
    echo ==========================================
    echo.
    echo If the GitHub repository already contains
    echo commits, you may need to pull first:
    echo.
    echo git pull --rebase origin main
    echo.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo              SUCCESS!
echo ==========================================
echo.

for /f "delims=" %%U in (
    'gh repo view "%REPO_NAME%" --json url --jq ".url"'
) do (
    echo GitHub repository:
    echo %%U
)

echo.
echo Fern V2 has been committed and pushed.
echo.
pause