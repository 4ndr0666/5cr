import mpm

def print_menu():
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
    print("16. Exit")

def search_package():
    package_name = input("Enter the name of the package you want to search for: ")
    results = mpm.search(package_name)
    if not results:
        print(f"No packages found for {package_name}")
    else:
        print(f"Found {len(results)} packages for {package_name}:")
        for package in results:
            print(f"{package['name']} - {package['description']}")

def install_package():
    package_name = input("Enter the name of the package you want to install: ")
    mpm.install(package_name)
    print(f"{package_name} installed successfully!")

def uninstall_package():
    package_name = input("Enter the name of the package you want to uninstall: ")
    mpm.uninstall(package_name)
    print(f"{package_name} uninstalled successfully!")

def list_installed_packages():
    installed_packages = mpm.list_installed()
    if not installed_packages:
        print("No packages installed")
    else:
        print("Installed packages:")
        for package in installed_packages:
            print(package)

def list_available_updates():
    updates = mpm.check_updates()
    if not updates:
        print("No available updates")
    else:
        print("Available updates:")
        for package, version in updates.items():
            print(f"{package} ({version})")

def update_package():
    package_name = input("Enter the name of the package you want to update: ")
    mpm.update(package_name)
    print(f"{package_name} updated successfully!")

def upgrade_all_packages():
    mpm.upgrade_all()
    print("All packages upgraded successfully!")

def xkcd_install():
    print("This is a joke option from the XKCD comic!")
    print("Please enter the name of the package you want to 'install':")
    package_name = input()
    print(f"{package_name} installed successfully!")

def pip_upgrade_all():
    mpm.pip_upgrade_all()
    print("All pip packages upgraded successfully!")

def search_exact():
    package_name = input("Enter the exact name of the package you want to search for: ")
    results = mpm.search_exact(package_name)
    if not results:
        print(f"No packages found for {package_name}")
    else:
        print(f"Found {len(results)} packages for {package_name}:")
        for package in results:
            print(f"{package['name']} - {package['description']}")

def list_duplicates():
    duplicate_packages = mpm.list_duplicates()
    if not duplicate_packages:
        print("No packages with duplicate IDs found")
    else:
        print("Packages with duplicate IDs:")
        for package in duplicate_packages:
            print(package)

def remove_duplicates():
    mpm.remove_duplicates()
    print("Packages with duplicate IDs removed successfully!")

def dump_packages():
    filename = input("Enter the name of the file to dump the installed packages to (including the extension): ")
mpm.snapshot(filename)
print("Installed packages dumped to file successfully!")

def update_dumped_packages():
filename = input("Enter the name of the file containing the dumped packages (including the extension): ")
mpm.snapshot_update(filename)
print("Dumped packages updated to latest version successfully!")

def merge_packages():
filename = input("Enter the name of the file containing the dumped packages (including the extension): ")
mpm.snapshot_merge(filename)
print("Latest installed packages merged with previous dump successfully!")

while True:
print_menu()
choice = input("Enter your choice: ")

if choice == '1':
    search_package()
elif choice == '2':
    install_package()
elif choice == '3':
    uninstall_package()
elif choice == '4':
    list_installed_packages()
elif choice == '5':
    list_available_updates()
elif choice == '6':
    update_package()
elif choice == '7':
    upgrade_all_packages()
elif choice == '8':
    xkcd_install()
elif choice == '9':
    pip_upgrade_all()
elif choice == '10':
    search_exact()
elif choice == '11':
    list_duplicates()
elif choice == '12':
    remove_duplicates()
elif choice == '13':
    dump_packages()
elif choice == '14':
    update_dumped_packages()
elif choice == '15':
    merge_packages()
elif choice == '16':
    print("Exiting...")
    break
else:
    print("Invalid choice. Please try again.")

