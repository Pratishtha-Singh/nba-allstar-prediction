@echo off
REM Fixed GitHub Setup Script - Handles spaces in paths properly

echo.
echo 🏀 NBA All-Star Prediction - Fixed GitHub Setup
echo ===============================================
echo.

REM Navigate to script directory
cd /d "%~dp0"

REM Set variables with proper quoting
set "REPO_NAME=nba-allstar-prediction"
set "REPO_DESCRIPTION=NBA All-Star Prediction using Machine Learning - Automated CI/CD Pipeline"

echo ℹ️ Current directory: %CD%

REM Check if we're in a git repository
if exist ".git" (
    echo ✅ Git repository already exists
) else (
    echo ℹ️ Initializing Git repository...
    git init
    if %ERRORLEVEL% NEQ 0 (
        echo ❌ Failed to initialize git repository
        pause
        exit /b 1
    )
    git branch -M main
    echo ✅ Git repository initialized
)

REM Create project structure
echo ℹ️ Setting up project structure...
if not exist "data\raw" mkdir "data\raw"
if not exist "data\processed" mkdir "data\processed"
if not exist "data\results" mkdir "data\results"
if not exist "notebooks" mkdir "notebooks"
if not exist "models" mkdir "models"
if not exist "docs" mkdir "docs"

REM Move notebook if it exists
if exist "project file.ipynb" (
    move "project file.ipynb" "notebooks\project_file.ipynb"
    echo ✅ Moved notebook to notebooks/
)

REM Move CSV files
for %%f in (*.csv) do (
    if exist "%%f" (
        move "%%f" "data\raw\"
        echo ✅ Moved %%f to data/raw/
    )
)

REM Check if there are any files to commit
echo ℹ️ Checking for files to commit...
git status --porcelain > temp_status.txt
set /p STATUS= < temp_status.txt
del temp_status.txt

if "%STATUS%"=="" (
    echo ⚠️ No files to commit. Adding all files...
    git add .
) else (
    echo ℹ️ Adding files to git...
    git add .
)

REM Check if there are staged changes
git diff --cached --quiet
if %ERRORLEVEL% EQU 0 (
    echo ⚠️ No changes staged. Creating initial commit...
    echo # NBA All-Star Prediction > README_temp.md
    git add README_temp.md
)

REM Commit changes
echo ℹ️ Committing files...
git commit -m "Initial commit: NBA All-Star Prediction Analysis"
if %ERRORLEVEL% NEQ 0 (
    echo ⚠️ Commit failed or no changes to commit
)

REM Create GitHub repository
echo ℹ️ Creating GitHub repository...
gh repo create "%REPO_NAME%" --description "%REPO_DESCRIPTION%" --public
if %ERRORLEVEL% NEQ 0 (
    echo ⚠️ Repository might already exist, continuing...
)

REM Add remote and push
echo ℹ️ Adding remote and pushing...
for /f "tokens=*" %%i in ('gh api user --jq .login') do set GITHUB_USERNAME=%%i
git remote remove origin 2>nul
git remote add origin "https://github.com/%GITHUB_USERNAME%/%REPO_NAME%.git"
git push -u origin main

if %ERRORLEVEL% EQ 0 (
    echo ✅ Successfully pushed to GitHub!
    
    echo.
    echo 🎉 SUCCESS! Repository created successfully!
    echo ==========================================
    echo.
    echo 🔗 Repository URL: https://github.com/%GITHUB_USERNAME%/%REPO_NAME%
    echo ⚡ GitHub Actions: https://github.com/%GITHUB_USERNAME%/%REPO_NAME%/actions
    echo 🌐 GitHub Pages: https://%GITHUB_USERNAME%.github.io/%REPO_NAME%/
    echo.
    echo 📈 Next steps:
    echo 1. Check GitHub Actions for CI/CD status
    echo 2. Wait for GitHub Pages deployment (~5 minutes)
    echo 3. Your analysis will be live online!
    
    set /p choice="🌐 Open repository in browser? (y/n): "
    if /i "%choice%"=="y" start "" "https://github.com/%GITHUB_USERNAME%/%REPO_NAME%"
    
) else (
    echo ❌ Failed to push to GitHub
    echo.
    echo 🔧 Troubleshooting steps:
    echo 1. Make sure you're authenticated: gh auth status
    echo 2. Check if repository exists: gh repo view %REPO_NAME%
    echo 3. Try manual push: git push -u origin main
)

echo.
pause
