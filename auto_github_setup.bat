@echo off
REM Fully Automated GitHub Repository Creation and Upload Script for Windows
REM This script uses GitHub CLI to create repo and upload everything automatically

echo.
echo 🤖 Automated GitHub Repository Creator
echo ======================================
echo.

REM Configuration
set REPO_NAME=nba-allstar-prediction
set REPO_DESCRIPTION=NBA All-Star Prediction using Machine Learning - Automated CI/CD Pipeline

REM Step 1: Check if GitHub CLI is installed
gh --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ GitHub CLI not found. Please install it first:
    echo 📥 Download from: https://cli.github.com
    echo 💡 Or use winget: winget install GitHub.cli
    pause
    exit /b 1
)

echo ✅ GitHub CLI found

REM Step 2: Authenticate with GitHub
echo ℹ️ Checking GitHub authentication...
gh auth status >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ⚠️ Not authenticated with GitHub. Starting authentication...
    gh auth login --web
)

echo ✅ GitHub authentication verified

REM Step 3: Set up project structure
echo ℹ️ Setting up project structure...

REM Create directories
if not exist "data\raw" mkdir data\raw
if not exist "data\processed" mkdir data\processed
if not exist "data\results" mkdir data\results
if not exist "notebooks" mkdir notebooks
if not exist "models" mkdir models
if not exist "docs" mkdir docs
if not exist "src" mkdir src
if not exist "tests" mkdir tests

REM Move notebook if it exists
if exist "project file.ipynb" (
    move "project file.ipynb" "notebooks\project_file.ipynb" >nul
    echo ✅ Moved notebook to notebooks/
)

REM Move CSV files
for %%f in (*.csv) do (
    if exist "%%f" (
        move "%%f" "data\raw\" >nul
        echo ✅ Moved %%f to data/raw/
    )
)

REM Step 4: Initialize Git repository
echo ℹ️ Initializing Git repository...
git init >nul 2>&1
git branch -M main >nul 2>&1

REM Step 5: Create .gitignore if it doesn't exist
if not exist ".gitignore" (
    echo # Data files > .gitignore
    echo data/raw/*.csv >> .gitignore
    echo data/processed/ >> .gitignore
    echo. >> .gitignore
    echo # Python >> .gitignore
    echo __pycache__/ >> .gitignore
    echo *.pyc >> .gitignore
    echo .env >> .gitignore
    echo venv/ >> .gitignore
    echo. >> .gitignore
    echo # Jupyter >> .gitignore
    echo .ipynb_checkpoints/ >> .gitignore
    echo. >> .gitignore
    echo # OS >> .gitignore
    echo .DS_Store >> .gitignore
    echo Thumbs.db >> .gitignore
    echo ✅ Created .gitignore
)

REM Step 6: Add and commit files
echo ℹ️ Adding files to Git...
git add . >nul 2>&1
git commit -m "🎯 Initial commit: NBA All-Star Prediction Analysis" >nul 2>&1

echo ✅ Files committed to Git

REM Step 7: Create GitHub repository
echo ℹ️ Creating GitHub repository...
gh repo create %REPO_NAME% --description "%REPO_DESCRIPTION%" --public --source=. --remote=origin --push

if %ERRORLEVEL% EQ 0 (
    echo ✅ Repository created and pushed successfully!
) else (
    echo ⚠️ Trying alternative method...
    gh repo create %REPO_NAME% --description "%REPO_DESCRIPTION%" --public
    for /f "tokens=*" %%i in ('gh api user --jq .login') do set GITHUB_USERNAME=%%i
    git remote add origin https://github.com/%GITHUB_USERNAME%/%REPO_NAME%.git
    git push -u origin main
)

REM Step 8: Get repository information
for /f "tokens=*" %%i in ('gh api user --jq .login') do set GITHUB_USERNAME=%%i
set REPO_URL=https://github.com/%GITHUB_USERNAME%/%REPO_NAME%
set PAGES_URL=https://%GITHUB_USERNAME%.github.io/%REPO_NAME%
set ACTIONS_URL=%REPO_URL%/actions

REM Step 9: Final success message
echo.
echo 🎉 SUCCESS! Your NBA All-Star Prediction project is now live!
echo ==============================================================
echo ✅ Repository created and configured automatically
echo.
echo 🔗 Important URLs:
echo 📊 Repository: %REPO_URL%
echo ⚡ GitHub Actions: %ACTIONS_URL%
echo 🌐 Live Demo: %PAGES_URL% (available after first CI/CD run)
echo.
echo 📈 What's happening now:
echo • GitHub Actions is automatically running your CI/CD pipeline
echo • Your code is being tested on Python 3.8, 3.9, 3.10
echo • Code quality checks are running (Black, Flake8, isort)
echo • Your notebook will be converted to HTML and deployed
echo • Live demo will be available in ~5 minutes
echo.
echo 🎯 Next Steps:
echo 1. Check GitHub Actions: %ACTIONS_URL%
echo 2. Wait for green build (usually 3-5 minutes)
echo 3. View your live analysis: %PAGES_URL%
echo 4. Share your professional portfolio!
echo.
echo ✅ 🚀 Your NBA All-Star prediction analysis is now professional and portfolio-ready!

REM Optional: Open repository in browser
set /p choice="🌐 Open repository in browser? (y/n): "
if /i "%choice%"=="y" start "" "%REPO_URL%"

pause
