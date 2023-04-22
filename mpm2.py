from meta_package_manager import MetaPackageManager
import json
import subprocess
import pkg_resources
import pip

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

def main():
    # ... other subparsers ...
    parser_outdated = subparsers.add_parser("outdated", help="List outdated packages")
    parser_outdated.set_defaults(func=outdated_packages)
    # ... rest of the main function ...

def outdated_packages(args):
    mpm = MetaPackageManager()
    outdated = mpm.outdated()
    for package in outdated:
        print(f"{package.manager} - {package.name} - {package.installed_version} -> {package.latest_version}")

def search_package():
    package_name = input("Enter the name of the package you want to search for: ")
    result = subprocess.run(['mpm', 'search', package_name], capture_output=True, text=True)
    print(result.stdout)

def list_installed(args):
    mpm = MetaPackageManager()
    installed = mpm.list()
    for manager, packages in installed.items():
        print(f"{manager}:")
        for package in packages:
            print(f"  {package.name} - {package.installed_version}")
        print()


def uninstall_package():
    package_name = input("Enter the name of the package you want to uninstall: ")
    result = subprocess.run(['mpm', 'uninstall', package_name], capture_output=True, text=True)
    print(result.stdout)

def list_installed_packages():
    result = subprocess.run(['mpm', 'list'], capture_output=True, text=True)
    print(result.stdout)

def list_available_updates():
    result = subprocess.run(['mpm', 'outdated'], capture_output=True, text=True)
    print(result.stdout)

def update_package():
    package_name = input("Enter the name of the package you want to update: ")
    result = subprocess.run(['mpm', 'update', package_name], capture_output=True, text=True)
    print(result.stdout)

def upgrade_all_packages():
    result = subprocess.run(['mpm', 'update'], capture_output=True, text=True)
    print(result.stdout)

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
    result = subprocess.run(['mpm', 'list', '--duplicates'], capture_output=True, text=True)
    print(result.stdout)

def remove_duplicates():
    result = subprocess.run(['mpm', 'list', '--duplicates'], capture_output=True, text=True)
    duplicate_packages = result.stdout.strip().split('\n')

    if not duplicate_packages or duplicate_packages == ['']:
        print("No packages with duplicate IDs found")
    else:
        print("Packages with duplicate IDs removed:")
        for package in duplicate_packages:
            package_name = package.split()[0]  # Extract the package name from the output
            subprocess.run(['mpm', 'uninstall', package_name], capture_output=True, text=True)
            print(package)

def dump_packages():
    installed_packages = pkg_resources.working_set
    filename = input("Enter the name of the file to dump the installed packages to (including the extension): ")
    with open(filename, 'w') as f:
        for package in installed_packages:
            package_info = {
                "name": package.project_name,
                "version": package.version,
                "location": package.location
            }
            json.dump(package_info, f)
            f.write('\n')
    print(f"Installed packages dumped to {filename} successfully!")

def update_dumped_packages():
    filename = input("Enter the name of the file containing the dumped packages (including the extension): ")
    with open(filename, 'r') as f:
        installed_packages = [json.loads(line.strip()) for line in f]
    updated_packages = manager.update_packages(installed_packages)
    with open(filename, 'w') as f:
        for package in updated_packages:
            json.dump(package, f)
            f.write('\n')
    print("Packages updated successfully!")

def merge_packages():
    previous_dump = input("Enter the name of the previous dump file (including the extension): ")
    current_dump = input("Enter the name of the current dump file (including the extension): ")
    with open(previous_dump, 'r') as f:
        previous_packages = [json.loads(line.strip()) for line in f]
    with open(current_dump, 'r') as f:
        current_packages = [json.loads(line.strip()) for line in f]
    merged_packages = set(previous_packages).union(set(current_packages))
    with open(current_dump, 'w') as f:
        for package in merged_packages:
            json.dump(package, f)
            f.write('\n')
    print("Packages merged successfully!")

while True:
    print_menu()
    choice = int(input("Enter your choice: "))
    if choice == 1:
        search_package()
    elif choice == 2:
        install_package()
    elif choice == 3:
        uninstall_package()
    elif choice == 4:
        list_installed_packages()
    elif choice == 5:
        list_available_updates()
    elif choice == 6:
        update_package()
    elif choice == 7:
        upgrade_all_packages()
    elif choice == 8:
        xkcd_install()
    elif choice == 9:
        pip_upgrade_all()
    elif choice == 10:
        search_exact()
    elif choice == 11:
        list_duplicates()
    elif choice == 12:
        remove_duplicates()
    elif choice == 13:
        dump_packages()
    elif choice == 14:
        update_dumped_packages()
    elif choice == 15:
        merge_packages()
    elif choice == 16:
        break
    else:
        print("Invalid choice, please try again.")
