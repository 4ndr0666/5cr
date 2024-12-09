#!/usr/bin/env python3

import os
import shutil
import datetime
import json
from pathlib import Path
import subprocess

# Global Definitions
XDG_CONFIG_HOME = Path(os.getenv("XDG_CONFIG_HOME", Path.home().joinpath(".config")))
XDG_DATA_HOME = Path(os.getenv("XDG_DATA_HOME", Path.home().joinpath(".local", "share")))
PROFILES_DIR = XDG_CONFIG_HOME.joinpath('BraveSoftware', 'Brave-Browser')
BACKUP_DIR = XDG_CONFIG_HOME.joinpath('BraveBackups')  # Updated to use XDG_CONFIG_HOME
BOOKMARKS_LOCATION = XDG_CONFIG_HOME.joinpath('bookmarks.md')  # Updated to use XDG_CONFIG_HOME

# Ensure the backup directory exists
BACKUP_DIR.mkdir(parents=True, exist_ok=True)

def check_dependencies():
    """Check for required dependencies before proceeding."""
    dependencies = ["sqlite3"]
    missing = []
    for dep in dependencies:
        if not shutil.which(dep):
            missing.append(dep)
    if missing:
        print(f"Missing dependencies: {', '.join(missing)}. Please install them to continue.")
        exit(1)

def list_profiles():
    """List available profiles."""
    profiles = [d.name for d in PROFILES_DIR.iterdir() if d.is_dir()]
    print(f"...{len(profiles)} total profiles available!")
    return profiles

def select_profile():
    """Allow user to select a profile."""
    profiles = list_profiles()
    for i, profile in enumerate(profiles, start=1):
        print(f"{i}) {profile}")
    try:
        choice = int(input("Enter the profile number: ")) - 1
        if 0 <= choice < len(profiles):
            return profiles[choice]
    except ValueError:
        print("Invalid selection. Please try again.")
    return None

def backup_profile(profile_name):
    """Backup selected profile."""
    profile_dir = PROFILES_DIR.joinpath(profile_name)
    timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    backup_path = BACKUP_DIR.joinpath(f"{profile_name}_{timestamp}")
    shutil.copytree(profile_dir, backup_path)
    print(f"Profile {profile_name} backed up successfully to {backup_path}.")

def restore_profile():
    """Restore a profile from backup."""
    print("Available backups:")
    backups = sorted([backup for backup in BACKUP_DIR.iterdir() if backup.is_dir()], key=os.path.getmtime, reverse=True)
    for i, backup in enumerate(backups, start=1):
        print(f"{i}) {backup.name}")

    try:
        choice = int(input("Enter the backup number: ")) - 1
        if 0 <= choice < len(backups):
            backup_selected = backups[choice]
            profile_name = backup_selected.name.split("_")[0]  # Assuming backup name format is 'ProfileName_timestamp'
            profile_dir = PROFILES_DIR.joinpath(profile_name)

            # Confirm restoration
            confirm = input(f"Restore '{profile_name}' from '{backup_selected.name}'? (yes/no): ")
            if confirm.lower() == 'yes':
                if profile_dir.exists():
                    shutil.rmtree(profile_dir)
                shutil.copytree(backup_selected, profile_dir)
                print(f"Restored '{profile_name}' from backup.")
            else:
                print("Restore cancelled.")
    except ValueError:
        print("Invalid selection. Please enter a number.")

def create_profile():
    """Create a new profile."""
    profile_name = input("Enter the new profile name: ").strip()
    new_profile_dir = PROFILES_DIR.joinpath(profile_name)
    if not new_profile_dir.exists():
        new_profile_dir.mkdir(parents=True)
        print(f"New profile '{profile_name}' created.")
    else:
        print("Profile already exists.")

def export_bookmarks():
    """Export bookmarks to markdown."""
    profile = select_profile()
    if profile:
        bookmarks_path = PROFILES_DIR.joinpath(profile, 'Bookmarks')
        if bookmarks_path.exists():
            with open(bookmarks_path, 'r', encoding='utf-8') as file:
                bookmarks = json.load(file)
                with open(BOOKMARKS_LOCATION, 'w', encoding='utf-8') as outfile:
                    outfile.write("## Brave Browser Bookmarks\n\n")
                    for item in bookmarks['roots']['bookmark_bar']['children']:
                        if item['type'] == 'url':
                            outfile.write(f"- [{item['name']}]({item['url']})\n")
            print(f"Bookmarks exported to {BOOKMARKS_LOCATION}.")
        else:
            print("No bookmarks file found.")

def main_menu():
    """Display the main menu."""
    print("=============== // Main Menu // =====================")
    print("1) Backup Profile")
    print("2) Restore Profile")
    print("3) Create New Profile")
    print("4) Export Bookmarks")
    print("0) Exit")
    print("====================================================")

def main():
    """Main function to run the script."""
    check_dependencies()  # Check for required dependencies at the start
    while True:
        main_menu()
        command = input("By your command: ")
        if command == '1':
            profile = select_profile()
            if profile: backup_profile(profile)
        elif command == '2':
            restore_profile()
        elif command == '3':
            create_profile()
        elif command == '4':
            export_bookmarks()
        elif command == '0':
            break
        else:
            print("Invalid input. Please select a valid option.")

if __name__ == "__main__":
    main()

