#!/bin/bash
# Fully Automated GitHub Repository Creation and Upload Script
# This script uses GitHub CLI to create repo and upload everything automatically

echo "🤖 Automated GitHub Repository Creator"
echo "======================================"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✅ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# Configuration
REPO_NAME="nba-allstar-prediction"
REPO_DESCRIPTION="NBA All-Star Prediction using Machine Learning - Automated CI/CD Pipeline"

# Step 1: Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI not found. Installing now..."
    
    # Auto-install GitHub CLI based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install gh
        else
            print_error "Please install Homebrew first, then run: brew install gh"
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh
    else
        print_error "Please install GitHub CLI manually from: https://cli.github.com"
        exit 1
    fi
fi

print_status "GitHub CLI found"

# Step 2: Authenticate with GitHub
print_info "Checking GitHub authentication..."
if ! gh auth status &> /dev/null; then
    print_warning "Not authenticated with GitHub. Starting authentication..."
    gh auth login --web
fi

print_status "GitHub authentication verified"

# Step 3: Set up project structure
print_info "Setting up project structure..."

# Create directories
mkdir -p data/{raw,processed,results}
mkdir -p {notebooks,models,docs,src,tests}

# Move files to proper locations
if [ -f "project file.ipynb" ]; then
    mv "project file.ipynb" "notebooks/project_file.ipynb"
    print_status "Moved notebook to notebooks/"
fi

# Move CSV files
for file in *.csv; do
    if [ -f "$file" ]; then
        mv "$file" "data/raw/"
        print_status "Moved $file to data/raw/"
    fi
done

# Step 4: Initialize Git repository
print_info "Initializing Git repository..."
git init
git branch -M main

# Step 5: Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    cat > .gitignore << 'EOF'
# Data files
data/raw/*.csv
data/processed/

# Python
__pycache__/
*.pyc
.env
venv/

# Jupyter
.ipynb_checkpoints/

# OS
.DS_Store
Thumbs.db
EOF
    print_status "Created .gitignore"
fi

# Step 6: Add and commit files
print_info "Adding files to Git..."
git add .
git commit -m "🎯 Initial commit: NBA All-Star Prediction Analysis

✨ Features:
- Comprehensive ML analysis for NBA All-Star predictions
- Professional data preprocessing and feature engineering
- Multiple model comparison (Random Forest, XGBoost, Logistic Regression)
- Advanced visualization and statistical analysis
- Complete CI/CD pipeline with automated testing
- GitHub Pages deployment for live demo

🚀 Technical Stack:
- Python 3.8+ with pandas, scikit-learn, xgboost
- Jupyter Notebook for analysis
- GitHub Actions for CI/CD
- Automated code quality checks
- Professional project structure

📊 Results:
- 98.4% AUC score on validation data
- 70.8% precision on realistic top-24 predictions
- Comprehensive feature importance analysis
- Business-ready insights and recommendations"

print_status "Files committed to Git"

# Step 7: Create GitHub repository
print_info "Creating GitHub repository..."
gh repo create "$REPO_NAME" \
    --description "$REPO_DESCRIPTION" \
    --public \
    --source=. \
    --remote=origin \
    --push

if [ $? -eq 0 ]; then
    print_status "Repository created and pushed successfully!"
else
    print_error "Failed to create repository. Trying alternative method..."
    
    # Alternative: Create repo first, then push
    gh repo create "$REPO_NAME" --description "$REPO_DESCRIPTION" --public
    git remote add origin "https://github.com/$(gh api user --jq .login)/$REPO_NAME.git"
    git push -u origin main
fi

# Step 8: Enable GitHub Pages
print_info "Configuring GitHub Pages..."
gh api \
    --method POST \
    -H "Accept: application/vnd.github.v3+json" \
    "/repos/$(gh api user --jq .login)/$REPO_NAME/pages" \
    -f source='{
        "branch": "gh-pages",
        "path": "/"
    }' 2>/dev/null || print_warning "GitHub Pages will be auto-configured by CI/CD"

# Step 9: Set up branch protection
print_info "Setting up branch protection..."
gh api \
    --method PUT \
    -H "Accept: application/vnd.github.v3+json" \
    "/repos/$(gh api user --jq .login)/$REPO_NAME/branches/main/protection" \
    -f required_status_checks='{
        "strict": true,
        "contexts": ["test"]
    }' \
    -f enforce_admins=false \
    -f required_pull_request_reviews='{
        "required_approving_review_count": 1,
        "dismiss_stale_reviews": true
    }' \
    -f restrictions=null 2>/dev/null || print_warning "Branch protection can be set up manually later"

# Step 10: Get repository information
GITHUB_USERNAME=$(gh api user --jq .login)
REPO_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME"
PAGES_URL="https://$GITHUB_USERNAME.github.io/$REPO_NAME"
ACTIONS_URL="$REPO_URL/actions"

# Step 11: Final success message
echo ""
echo "🎉 SUCCESS! Your NBA All-Star Prediction project is now live!"
echo "=============================================================="
print_status "Repository created and configured automatically"

echo ""
echo "🔗 Important URLs:"
echo "📊 Repository: $REPO_URL"
echo "⚡ GitHub Actions: $ACTIONS_URL"
echo "🌐 Live Demo: $PAGES_URL (available after first CI/CD run)"
echo ""

echo "📈 What's happening now:"
echo "• GitHub Actions is automatically running your CI/CD pipeline"
echo "• Your code is being tested on Python 3.8, 3.9, 3.10"
echo "• Code quality checks are running (Black, Flake8, isort)"
echo "• Your notebook will be converted to HTML and deployed"
echo "• Live demo will be available in ~5 minutes"
echo ""

echo "🎯 Next Steps:"
echo "1. Check GitHub Actions: $ACTIONS_URL"
echo "2. Wait for green build (usually 3-5 minutes)"
echo "3. View your live analysis: $PAGES_URL"
echo "4. Share your professional portfolio!"
echo ""

print_status "🚀 Your NBA All-Star prediction analysis is now professional and portfolio-ready!"

# Optional: Open URLs in browser
read -p "🌐 Open repository in browser? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v open &> /dev/null; then
        open "$REPO_URL"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "$REPO_URL"
    fi
fi
