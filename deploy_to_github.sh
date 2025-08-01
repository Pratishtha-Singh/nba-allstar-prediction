#!/bin/bash

# NBA All-Star Prediction - GitHub Setup and Deployment Script
# This script will help you upload your project to GitHub and set up CI/CD

echo "🏀 NBA All-Star Prediction - GitHub Setup Script"
echo "================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Please install Git first."
    exit 1
fi

print_info "Starting GitHub setup process..."

# Step 1: Check current directory
echo ""
echo "📁 Step 1: Checking project structure"
if [ ! -f "requirements.txt" ]; then
    print_warning "requirements.txt not found. Make sure you're in the project directory."
fi

if [ ! -f ".github/workflows/ci-cd.yml" ]; then
    print_error "CI/CD workflow file not found. Make sure all files are properly set up."
    exit 1
fi

print_status "Project files found"

# Step 2: Initialize git repository
echo ""
echo "🔧 Step 2: Setting up Git repository"

if [ ! -d ".git" ]; then
    git init
    git branch -M main
    print_status "Git repository initialized"
else
    print_info "Git repository already exists"
fi

# Step 3: Set up project structure
echo ""
echo "📂 Step 3: Organizing project structure"

# Create directories
mkdir -p data/raw data/processed data/results
mkdir -p notebooks models docs

# Move files if they exist
if [ -f "project file.ipynb" ]; then
    mv "project file.ipynb" "notebooks/project_file.ipynb"
    print_status "Moved notebook to notebooks/ directory"
fi

# Move CSV files to data/raw
for file in *.csv; do
    if [ -f "$file" ]; then
        mv "$file" "data/raw/"
        print_status "Moved $file to data/raw/"
    fi
done

print_status "Project structure organized"

# Step 4: Add files to git
echo ""
echo "📝 Step 4: Adding files to Git"

git add .
git commit -m "Initial commit: NBA All-Star prediction project with CI/CD

- Added comprehensive machine learning analysis notebook
- Implemented data processing and feature engineering modules  
- Set up automated testing and code quality checks
- Configured GitHub Pages deployment
- Added professional documentation and project structure"

print_status "Files committed to Git"

# Step 5: Get GitHub repository information
echo ""
echo "🐙 Step 5: GitHub Repository Setup"
print_info "Now you need to create a GitHub repository and get the URL"

echo ""
echo "Please follow these steps:"
echo "1. Go to https://github.com/new"
echo "2. Repository name: nba-allstar-prediction"
echo "3. Description: NBA All-Star Prediction using Machine Learning"
echo "4. Make it Public (recommended) or Private"
echo "5. Do NOT initialize with README, .gitignore, or license"
echo "6. Click 'Create repository'"
echo ""

read -p "Enter your GitHub username: " github_username
read -p "Enter the repository name (default: nba-allstar-prediction): " repo_name
repo_name=${repo_name:-nba-allstar-prediction}

# Step 6: Add remote and push
echo ""
echo "🚀 Step 6: Pushing to GitHub"

git_url="https://github.com/${github_username}/${repo_name}.git"
print_info "Repository URL: $git_url"

git remote add origin "$git_url"

echo ""
print_warning "You'll need to authenticate with GitHub. Options:"
echo "  1. Use GitHub CLI (gh auth login) - Recommended"
echo "  2. Use Personal Access Token"
echo "  3. Use SSH key"
echo ""

read -p "Press Enter when ready to push to GitHub..."

if git push -u origin main; then
    print_status "Successfully pushed to GitHub!"
else
    print_error "Failed to push to GitHub. Please check your authentication."
    echo ""
    echo "Troubleshooting tips:"
    echo "1. Make sure the repository exists on GitHub"
    echo "2. Check your GitHub authentication"
    echo "3. Try: git push -u origin main --force (if needed)"
    exit 1
fi

# Step 7: Set up GitHub Pages
echo ""
echo "🌐 Step 7: Setting up GitHub Pages"
print_info "Your CI/CD pipeline will automatically set up GitHub Pages"
print_info "After the first successful build, your notebook will be available at:"
print_info "https://${github_username}.github.io/${repo_name}/"

# Step 8: Enable GitHub Actions
echo ""
echo "⚡ Step 8: GitHub Actions Setup"
print_info "GitHub Actions should automatically start running"
print_info "Check the status at: https://github.com/${github_username}/${repo_name}/actions"

# Step 9: Final instructions
echo ""
echo "🎉 Setup Complete!"
echo "=================="
print_status "Your NBA All-Star prediction project is now on GitHub with CI/CD!"

echo ""
echo "📊 What happens next:"
echo "• GitHub Actions will run automatically and:"
echo "  - Test your code on Python 3.8, 3.9, 3.10"
echo "  - Check code quality (formatting, linting)"
echo "  - Run unit tests"
echo "  - Execute your notebook (if data is available)"
echo "  - Deploy to GitHub Pages"
echo ""

echo "🔗 Important URLs:"
echo "• Repository: https://github.com/${github_username}/${repo_name}"
echo "• Actions: https://github.com/${github_username}/${repo_name}/actions"
echo "• GitHub Pages: https://${github_username}.github.io/${repo_name}/"
echo ""

echo "📝 Next steps:"
echo "1. Check GitHub Actions tab to see your first build"
echo "2. Add your data files to data/raw/ directory"
echo "3. Update README.md with your information"
echo "4. Enable branch protection in repository settings"
echo ""

print_status "Happy coding! 🚀"
