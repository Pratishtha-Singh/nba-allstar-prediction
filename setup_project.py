"""
Setup script for organizing the NBA All-Star prediction project for GitHub.
Run this script to move files to proper locations and set up the project structure.
"""

import os
import shutil
from pathlib import Path


def setup_project_structure():
    """Set up the proper project structure for GitHub."""
    
    project_root = Path(__file__).parent
    
    # Create data directories
    data_dir = project_root / "data"
    data_dir.mkdir(exist_ok=True)
    (data_dir / "raw").mkdir(exist_ok=True)
    (data_dir / "processed").mkdir(exist_ok=True)
    (data_dir / "results").mkdir(exist_ok=True)
    
    # Create other directories
    (project_root / "models").mkdir(exist_ok=True)
    (project_root / "docs").mkdir(exist_ok=True)
    
    # Move CSV files to data/raw if they exist
    csv_files = ["player_data.csv", "Seasons_Stats.csv", "All_Star.csv"]
    for csv_file in csv_files:
        if (project_root / csv_file).exists():
            shutil.move(
                str(project_root / csv_file),
                str(data_dir / "raw" / csv_file)
            )
            print(f"Moved {csv_file} to data/raw/")
    
    # Move notebook to notebooks folder if it exists
    notebook_file = "project file.ipynb"
    if (project_root / notebook_file).exists():
        shutil.move(
            str(project_root / notebook_file),
            str(project_root / "notebooks" / "project_file.ipynb")
        )
        print(f"Moved {notebook_file} to notebooks/project_file.ipynb")
    
    print("Project structure setup complete!")
    print("\nNext steps:")
    print("1. Initialize git repository: git init")
    print("2. Add files: git add .")
    print("3. Commit: git commit -m 'Initial commit: NBA All-Star prediction project'")
    print("4. Create GitHub repository and push")
    print("5. Enable GitHub Actions for CI/CD")


if __name__ == "__main__":
    setup_project_structure()
