@echo off
REM NBA All-Star Prediction - GitHub Setup Script for Windows
REM This batch file will help you upload your project to GitHub and set up CI/CD

echo.
echo 🏀 NBA All-Star Prediction - GitHub Setup Script
echo =================================================
echo.

REM Check if git is installed
git --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Git is not installed. Please install Git first.
    echo Download from: https://git-scm.com/download/win
    pause
    exit /b 1
)

echo ℹ️ Starting GitHub setup process...

REM Step 1: Check project structure
echo.
echo 📁 Step 1: Checking project structure
if not exist "requirements.txt" (
    echo ⚠️ requirements.txt not found. Make sure you're in the project directory.
)

if not exist ".github\workflows\ci-cd.yml" (
    echo ❌ CI/CD workflow file not found. Make sure all files are properly set up.
    pause
    exit /b 1
)

echo ✅ Project files found

REM Step 2: Initialize git repository  
echo.
echo 🔧 Step 2: Setting up Git repository

if not exist ".git" (
    git init
    git branch -M main
    echo ✅ Git repository initialized
) else (
    echo ℹ️ Git repository already exists
)

REM Step 3: Set up project structure
echo.
echo 📂 Step 3: Organizing project structure

REM Create directories
if not exist "data\raw" mkdir data\raw
if not exist "data\processed" mkdir data\processed  
if not exist "data\results" mkdir data\results
if not exist "notebooks" mkdir notebooks
if not exist "models" mkdir models
if not exist "docs" mkdir docs

REM Move notebook if it exists
if exist "project file.ipynb" (
    move "project file.ipynb" "notebooks\project_file.ipynb"
    echo ✅ Moved notebook to notebooks/ directory
)

REM Move CSV files to data/raw
for %%f in (*.csv) do (
    if exist "%%f" (
        move "%%f" "data\raw\"
        echo ✅ Moved %%f to data/raw/
    )
)

echo ✅ Project structure organized

REM Step 4: Add files to git
echo.
echo 📝 Step 4: Adding files to Git

git add .
git commit -m "Initial commit: NBA All-Star prediction project with CI/CD

- Added comprehensive machine learning analysis notebook
- Implemented data processing and feature engineering modules  
- Set up automated testing and code quality checks
- Configured GitHub Pages deployment
- Added professional documentation and project structure"

echo ✅ Files committed to Git

REM Step 5: Get GitHub repository information
echo.
echo 🐙 Step 5: GitHub Repository Setup
echo ℹ️ Now you need to create a GitHub repository and get the URL
echo.
echo Please follow these steps:
echo 1. Go to https://github.com/new
echo 2. Repository name: nba-allstar-prediction
echo 3. Description: NBA All-Star Prediction using Machine Learning
echo 4. Make it Public (recommended) or Private
echo 5. Do NOT initialize with README, .gitignore, or license
echo 6. Click 'Create repository'
echo.

set /p github_username="Enter your GitHub username: "
set /p repo_name="Enter the repository name (default: nba-allstar-prediction): "
if "%repo_name%"=="" set repo_name=nba-allstar-prediction

REM Step 6: Add remote and push
echo.
echo 🚀 Step 6: Pushing to GitHub
echo ℹ️ Repository URL: https://github.com/%github_username%/%repo_name%.git

git remote add origin https://github.com/%github_username%/%repo_name%.git

echo.
echo ⚠️ You'll need to authenticate with GitHub. Options:
echo   1. Use GitHub CLI (gh auth login) - Recommended
echo   2. Use Personal Access Token
echo   3. Use SSH key
echo.
pause

git push -u origin main
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to push to GitHub. Please check your authentication.
    echo.
    echo Troubleshooting tips:
    echo 1. Make sure the repository exists on GitHub
    echo 2. Check your GitHub authentication
    echo 3. Try: git push -u origin main --force (if needed)
    pause
    exit /b 1
)

echo ✅ Successfully pushed to GitHub!

REM Step 7: Final instructions
echo.
echo 🎉 Setup Complete!
echo ==================
echo ✅ Your NBA All-Star prediction project is now on GitHub with CI/CD!

echo.
echo 📊 What happens next:
echo • GitHub Actions will run automatically and:
echo   - Test your code on Python 3.8, 3.9, 3.10
echo   - Check code quality (formatting, linting)
echo   - Run unit tests
echo   - Execute your notebook (if data is available)
echo   - Deploy to GitHub Pages
echo.

echo 🔗 Important URLs:
echo • Repository: https://github.com/%github_username%/%repo_name%
echo • Actions: https://github.com/%github_username%/%repo_name%/actions
echo • GitHub Pages: https://%github_username%.github.io/%repo_name%/
echo.

echo 📝 Next steps:
echo 1. Check GitHub Actions tab to see your first build
echo 2. Add your data files to data/raw/ directory
echo 3. Update README.md with your information
echo 4. Enable branch protection in repository settings
echo.

echo ✅ Happy coding! 🚀
pause
