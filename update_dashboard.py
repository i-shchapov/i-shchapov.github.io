#!/usr/bin/env python3
"""
Update dashboard files from EconJobMarketStats repository.

This script copies the latest dashboard HTML files from the EconJobMarketStats
output directory to the website's dashboard directory.
"""

import os
import shutil
from pathlib import Path

# Define paths
DASHBOARD_SOURCE = Path("/Users/ivanshchapov/Documents/EconJobMarketStats/output/phd_dashboard")
DASHBOARD_DEST = Path(__file__).parent / "dashboard"

def update_dashboard():
    """Copy all *_ivan.html files from source to destination."""

    # Check if source directory exists
    if not DASHBOARD_SOURCE.exists():
        print(f"Error: Source directory not found: {DASHBOARD_SOURCE}")
        return False

    # Create destination directory if it doesn't exist
    DASHBOARD_DEST.mkdir(exist_ok=True)

    # Find all *_ivan.html files (excluding jobs_browser_ivan.html)
    html_files = [f for f in DASHBOARD_SOURCE.glob("*_ivan.html")
                  if f.name != "jobs_browser_ivan.html"]

    if not html_files:
        print(f"Warning: No *_ivan.html files found in {DASHBOARD_SOURCE}")
        return False

    # Copy files
    copied_count = 0
    for file_path in html_files:
        dest_path = DASHBOARD_DEST / file_path.name
        try:
            shutil.copy2(file_path, dest_path)
            copied_count += 1
            print(f"✓ Copied: {file_path.name}")
        except Exception as e:
            print(f"✗ Failed to copy {file_path.name}: {e}")

    print(f"\nSuccessfully copied {copied_count}/{len(html_files)} dashboard files.")
    return True

if __name__ == "__main__":
    print("Updating dashboard files...\n")
    success = update_dashboard()

    if success:
        print("\nDashboard update complete!")
        print("Run 'quarto render' to rebuild the website.")
    else:
        print("\nDashboard update failed.")
        exit(1)
