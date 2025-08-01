# GitHub & CI/CD Setup Guide

## 📋 Overview

This guide will walk you through setting up your NBA All-Star prediction project on GitHub with a complete CI/CD pipeline.

## 🚀 Step-by-Step Setup

### Step 1: Organize Your Project Structure

1. **Run the setup script** (in your project directory):
   ```bash
   python setup_project.py
   ```

2. **Your final structure should look like this**:
   ```
   nba-allstar-prediction/
   ├── data/
   │   └── raw/                    # Your CSV files go here
   │       ├── player_data.csv
   │       ├── Seasons_Stats.csv
   │       └── All_Star.csv
   ├── notebooks/
   │   └── project_file.ipynb      # Your main notebook
   ├── src/                        # Python modules
   ├── tests/                      # Test files
   ├── .github/workflows/          # CI/CD configuration
   ├── requirements.txt
   ├── README.md
   └── other config files...
   ```

### Step 2: Initialize Git Repository

1. **Open terminal/command prompt** in your project folder
2. **Initialize git**:
   ```bash
   git init
   git branch -M main
   ```

3. **Add all files**:
   ```bash
   git add .
   ```

4. **Make first commit**:
   ```bash
   git commit -m "Initial commit: NBA All-Star prediction project"
   ```

### Step 3: Create GitHub Repository

1. **Go to GitHub.com** and log in
2. **Click "New repository"**
3. **Repository settings**:
   - Name: `nba-allstar-prediction`
   - Description: "NBA All-Star Prediction using Machine Learning"
   - Public or Private (your choice)
   - ⚠️ **Don't initialize with README** (we already have one)

4. **Push your code**:
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/nba-allstar-prediction.git
   git push -u origin main
   ```

### Step 4: Set Up CI/CD Pipeline

The CI/CD pipeline is already configured! Here's what it does:

#### **Continuous Integration (CI)**
- ✅ **Code Quality Checks**: Black formatting, isort imports, flake8 linting
- ✅ **Testing**: Runs pytest test suite
- ✅ **Multi-Python Support**: Tests on Python 3.8, 3.9, 3.10
- ✅ **Notebook Validation**: Executes notebook to ensure it runs without errors

#### **Continuous Deployment (CD)**
- 🚀 **GitHub Pages**: Automatically converts notebook to HTML and deploys
- 📊 **Coverage Reports**: Uploads test coverage to Codecov
- 🔄 **Automatic Updates**: Runs on every push to main branch

### Step 5: Enable GitHub Actions

1. **In your GitHub repository**, go to **"Actions"** tab
2. **GitHub Actions should automatically detect** your workflow file
3. **First run will happen** when you push code
4. **Monitor the build** - should turn green if everything works!

### Step 6: Set Up GitHub Pages (Optional)

1. **Go to repository Settings**
2. **Scroll to "Pages" section**
3. **Source**: Deploy from a branch
4. **Branch**: `gh-pages` (will be created automatically by CI/CD)
5. **Your notebook will be available** at: `https://YOUR_USERNAME.github.io/nba-allstar-prediction/`

## 🔧 Development Workflow

### Making Changes

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/new-analysis
   ```

2. **Make your changes** (code, notebook, etc.)

3. **Run tests locally**:
   ```bash
   pip install -r requirements.txt
   pytest tests/ -v
   black src/ tests/
   flake8 src/
   ```

4. **Commit and push**:
   ```bash
   git add .
   git commit -m "Add new feature: advanced player clustering"
   git push origin feature/new-analysis
   ```

5. **Create Pull Request** on GitHub

6. **CI/CD will automatically**:
   - Run all tests
   - Check code quality
   - Execute notebook
   - Report results

### Branch Protection (Recommended)

1. **Go to Settings > Branches**
2. **Add rule for `main` branch**:
   - ✅ Require status checks to pass
   - ✅ Require branches to be up to date
   - ✅ Require pull request reviews

## 📊 Monitoring & Badges

Add these badges to your README to show project status:

```markdown
[![CI/CD Pipeline](https://github.com/YOUR_USERNAME/nba-allstar-prediction/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/YOUR_USERNAME/nba-allstar-prediction/actions/workflows/ci-cd.yml)
[![Python Version](https://img.shields.io/badge/python-3.8%2B-blue.svg)](https://python.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
```

## 🐛 Troubleshooting

### Common Issues

1. **Notebook fails to execute**:
   - Ensure all data files are in `data/raw/`
   - Check file paths in notebook
   - Verify all dependencies in `requirements.txt`

2. **Tests fail**:
   - Run tests locally first: `pytest tests/ -v`
   - Check import paths
   - Ensure test data is available

3. **GitHub Actions fails**:
   - Check the Actions tab for detailed error logs
   - Common issue: missing dependencies in `requirements.txt`

4. **Pages deployment fails**:
   - Ensure `gh-pages` branch exists
   - Check GitHub Pages settings
   - Verify workflow has write permissions

### Data Security Note

⚠️ **Important**: Your CSV data files are in `.gitignore` by default to prevent accidental upload of large datasets. If you want to include sample data:

1. Create small sample files
2. Remove them from `.gitignore`
3. Or use Git LFS for large files

## 🎯 Next Steps

1. **Customize the README** with your information
2. **Add more tests** for better coverage
3. **Set up code coverage** with Codecov
4. **Add documentation** with Sphinx
5. **Consider containerization** with Docker
6. **Add deployment** to cloud platforms

## 📞 Support

If you encounter issues:
1. Check GitHub Actions logs
2. Review this guide
3. Check GitHub documentation
4. Create an issue in your repository

---

**Happy coding! 🚀**
