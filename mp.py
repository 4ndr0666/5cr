#!/usr/bin/env python3

import os
import sys
import toml
from meta_package_manager import ManagerPool

CONFIG_DIR = os.path.expanduser("~/.config/mpm")
CONFIG_FILE = os.path.join(CONFIG_DIR, "packages.toml")

def print_menu():
    print("\nMenu:")
    print("1. Search for a package")
    print("2. Install a package")
    print("3. Uninstall a package")
    print("4. List installed packages")
    print("5. List available updates")
    print("6. Update a package")
    print("7. Upgrade all packages")
    print("8. Install packages with xkcd")
    print("9. Upgrade all pip packages")
    print("10. Search for a package exactly")
    print("11. List installed packages with duplicate IDs")
    print("12. Remove packages with duplicate IDs")
    print("13. Dump installed packages to file")
    print("14. Update dumped packages to latest version")
    print("15. Merge latest installed packages with previous dump")
    print("16. Run the doctor command in mpm")
    print("17. Exit")

def save_to_config(data):
    if not os.path.exists(CONFIG_DIR):
        os.makedirs(CONFIG_DIR)
    with open(CONFIG_FILE, "w") as f:
        toml.dump(data, f)

def load_config():
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, "r") as f:
            return toml.load(f)
    return {}

def main():
    pool = ManagerPool(allow_cli=True)
    pool.load_managers()

    while True:
        print_menu()
        choice = int(input("\nEnter your choice: "))
        
        if choice == 1:
            package_name = input("Enter the package name to search: ")
            search_package(pool, package_name)
        elif choice == 2:
            package_name = input("Enter the package name to install: ")
            install_package(pool, package_name)
        elif choice == 3:
            package_name = input("Enter the package name to uninstall: ")
            uninstall_package(pool, package_name)
        elif choice == 4:
            list_installed_packages(pool)
        elif choice == 5:
            list_available_updates(pool)
        elif choice == 6:
            package_name = input("Enter the package name to update: ")
            update_package(pool, package_name)
        elif choice == 7:
            upgrade_all_packages(pool)
        elif choice == 8:
            print("This feature is not supported by the meta-package-manager.")
        elif choice == 9:
            upgrade_all_pip_packages(pool)
        elif choice == 10:
            package_name = input("Enter the package name to search exactly: ")
            search_exact_package(pool, package_name)
        elif choice == 11:
            list_duplicate_installed_packages(pool)
        elif choice == 12:
            remove_duplicate_packages(pool)
        elif choice == 13:
            dump_installed_packages(pool)
        elif choice == 14:
            update_dumped_packages(pool)
        elif choice == 15:
            merge_latest_installed_packages(pool)
        elif choice == 16:
            run_doctor_command(pool)
        elif choice == 17:
            print("Exiting...")
            break
        else:
            print("Invalid choice. Please enter a valid number.")

if __name__ == "__main__":
    main()
