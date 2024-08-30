#!/usr/bin/env python3

import os
import sys
import subprocess

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

def run_command(command):
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, error = process.communicate()
    if output:
        print(output.decode())
    if error:
        print(error.decode())

def main():
    while True:
        print_menu()
        choice = int(input("\nEnter your choice: "))
        
        if choice == 1:
            package_name = input("Enter the package name to search: ")
            run_command(["mpm", "search", package_name])
        elif choice == 2:
            package_name = input("Enter the package name to install: ")
            run_command(["mpm", "install", package_name])
        elif choice == 3:
            package_name = input("Enter the package name to uninstall: ")
            run_command(["mpm", "remove", package_name])
        elif choice == 4:
            run_command(["mpm", "list"])
        elif choice == 5:
            run_command(["mpm", "outdated"])
        elif choice == 6:
            package_name = input("Enter the package name to update: ")
            run_command(["mpm", "update", package_name])
        elif choice == 7:
            run_command(["mpm", "upgrade"])
        # The rest of the cases require custom handling or are not supported by the meta-package-manager
        else:
            print("This feature is not supported by the meta-package-manager. Please choose an option from 1 to 7, or 17 to exit.")

        if choice == 17:
            print("Exiting...")
            break

if __name__ == "__main__":
    main()
