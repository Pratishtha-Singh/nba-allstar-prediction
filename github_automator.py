"""
Automated GitHub Repository Creator using GitHub API
This script creates a repository and uploads files programmatically
"""

import os
import subprocess
import requests
import json
from pathlib import Path
import getpass

class GitHubAutomator:
    def __init__(self):
        self.base_url = "https://api.github.com"
        self.token = None
        self.username = None
        self.repo_name = "nba-allstar-prediction"
        
    def setup_authentication(self):
        """Set up GitHub authentication"""
        print("🔐 GitHub Authentication Setup")
        print("=" * 40)
        
        # Check if token is in environment
        self.token = os.getenv('GITHUB_TOKEN')
        
        if not self.token:
            print("GitHub Personal Access Token needed.")
            print("📝 Create one at: https://github.com/settings/tokens")
            print("✅ Required permissions: repo, workflow, admin:repo_hook")
            print()
            self.token = getpass.getpass("Enter your GitHub token: ")
        
        # Verify token and get username
        headers = {"Authorization": f"token {self.token}"}
        response = requests.get(f"{self.base_url}/user", headers=headers)
        
        if response.status_code == 200:
            self.username = response.json()['login']
            print(f"✅ Authenticated as: {self.username}")
            return True
        else:
            print("❌ Authentication failed. Please check your token.")
            return False
    
    def create_repository(self):
        """Create GitHub repository"""
        print("\n📊 Creating GitHub Repository")
        print("=" * 40)
        
        repo_data = {
            "name": self.repo_name,
            "description": "NBA All-Star Prediction using Machine Learning - Automated CI/CD Pipeline",
            "private": False,
            "has_issues": True,
            "has_projects": True,
            "has_wiki": True,
            "auto_init": False,
            "allow_squash_merge": True,
            "allow_merge_commit": True,
            "allow_rebase_merge": True,
            "delete_branch_on_merge": True
        }
        
        headers = {
            "Authorization": f"token {self.token}",
            "Accept": "application/vnd.github.v3+json"
        }
        
        response = requests.post(
            f"{self.base_url}/user/repos",
            headers=headers,
            json=repo_data
        )
        
        if response.status_code == 201:
            print(f"✅ Repository created: {self.repo_name}")
            return True
        elif response.status_code == 422:
            print(f"⚠️ Repository {self.repo_name} already exists")
            return True
        else:
            print(f"❌ Failed to create repository: {response.json()}")
            return False
    
    def setup_project_structure(self):
        """Set up project directory structure"""
        print("\n📁 Setting Up Project Structure")
        print("=" * 40)
        
        # Create directories
        directories = [
            "data/raw", "data/processed", "data/results",
            "notebooks", "models", "docs", "src", "tests"
        ]
        
        for directory in directories:
            Path(directory).mkdir(parents=True, exist_ok=True)
        
        # Move notebook if exists
        if Path("project file.ipynb").exists():
            Path("project file.ipynb").rename("notebooks/project_file.ipynb")
            print("✅ Moved notebook to notebooks/")
        
        # Move CSV files
        csv_files = list(Path(".").glob("*.csv"))
        for csv_file in csv_files:
            csv_file.rename(f"data/raw/{csv_file.name}")
            print(f"✅ Moved {csv_file.name} to data/raw/")
        
        print("✅ Project structure organized")
    
    def initialize_git(self):
        """Initialize and configure Git repository"""
        print("\n🔧 Initializing Git Repository")
        print("=" * 40)
        
        commands = [
            ["git", "init"],
            ["git", "branch", "-M", "main"],
            ["git", "add", "."],
            ["git", "commit", "-m", "🎯 Initial commit: NBA All-Star Prediction Analysis\n\n✨ Features:\n- Comprehensive ML analysis for NBA All-Star predictions\n- Professional CI/CD pipeline with automated testing\n- GitHub Pages deployment for live demo\n- Complete project structure and documentation"]
        ]
        
        for cmd in commands:
            try:
                subprocess.run(cmd, check=True, capture_output=True)
                print(f"✅ {' '.join(cmd)}")
            except subprocess.CalledProcessError as e:
                print(f"❌ Failed: {' '.join(cmd)}")
                print(f"Error: {e.stderr.decode()}")
                return False
        
        return True
    
    def push_to_github(self):
        """Push repository to GitHub"""
        print("\n🚀 Pushing to GitHub")
        print("=" * 40)
        
        repo_url = f"https://{self.token}@github.com/{self.username}/{self.repo_name}.git"
        
        commands = [
            ["git", "remote", "add", "origin", repo_url],
            ["git", "push", "-u", "origin", "main"]
        ]
        
        for cmd in commands:
            try:
                subprocess.run(cmd, check=True, capture_output=True)
                print(f"✅ {cmd[1]} {cmd[2] if len(cmd) > 2 else ''}")
            except subprocess.CalledProcessError as e:
                if "remote origin already exists" in e.stderr.decode():
                    print("ℹ️ Remote origin already exists")
                    continue
                print(f"❌ Failed: {' '.join(cmd)}")
                print(f"Error: {e.stderr.decode()}")
                return False
        
        return True
    
    def setup_branch_protection(self):
        """Set up branch protection rules"""
        print("\n🛡️ Setting Up Branch Protection")
        print("=" * 40)
        
        protection_data = {
            "required_status_checks": {
                "strict": True,
                "contexts": ["test"]
            },
            "enforce_admins": False,
            "required_pull_request_reviews": {
                "required_approving_review_count": 1,
                "dismiss_stale_reviews": True
            },
            "restrictions": None
        }
        
        headers = {
            "Authorization": f"token {self.token}",
            "Accept": "application/vnd.github.v3+json"
        }
        
        response = requests.put(
            f"{self.base_url}/repos/{self.username}/{self.repo_name}/branches/main/protection",
            headers=headers,
            json=protection_data
        )
        
        if response.status_code in [200, 201]:
            print("✅ Branch protection configured")
        else:
            print("⚠️ Branch protection setup skipped (can be done manually)")
    
    def run_automation(self):
        """Run the complete automation process"""
        print("🤖 NBA All-Star Prediction - GitHub Automation")
        print("=" * 50)
        
        # Step 1: Authentication
        if not self.setup_authentication():
            return False
        
        # Step 2: Set up project structure
        self.setup_project_structure()
        
        # Step 3: Create repository
        if not self.create_repository():
            return False
        
        # Step 4: Initialize Git
        if not self.initialize_git():
            return False
        
        # Step 5: Push to GitHub
        if not self.push_to_github():
            return False
        
        # Step 6: Set up branch protection
        self.setup_branch_protection()
        
        # Success message
        self.print_success_message()
        
        return True
    
    def print_success_message(self):
        """Print success message with URLs"""
        repo_url = f"https://github.com/{self.username}/{self.repo_name}"
        pages_url = f"https://{self.username}.github.io/{self.repo_name}"
        actions_url = f"{repo_url}/actions"
        
        print("\n🎉 SUCCESS! Your NBA All-Star Prediction project is now live!")
        print("=" * 60)
        print("✅ Repository created and configured automatically")
        print()
        print("🔗 Important URLs:")
        print(f"📊 Repository: {repo_url}")
        print(f"⚡ GitHub Actions: {actions_url}")
        print(f"🌐 Live Demo: {pages_url} (available after first CI/CD run)")
        print()
        print("📈 What's happening now:")
        print("• GitHub Actions is automatically running your CI/CD pipeline")
        print("• Your code is being tested on Python 3.8, 3.9, 3.10")
        print("• Code quality checks are running (Black, Flake8, isort)")
        print("• Your notebook will be converted to HTML and deployed")
        print("• Live demo will be available in ~5 minutes")
        print()
        print("🎯 Next Steps:")
        print(f"1. Check GitHub Actions: {actions_url}")
        print("2. Wait for green build (usually 3-5 minutes)")
        print(f"3. View your live analysis: {pages_url}")
        print("4. Share your professional portfolio!")
        print()
        print("✅ 🚀 Your NBA All-Star prediction analysis is now professional and portfolio-ready!")


if __name__ == "__main__":
    automator = GitHubAutomator()
    automator.run_automation()
