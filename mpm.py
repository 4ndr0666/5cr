import mpm
import pkg_resources

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


def find_duplicates():
    packages = pkg_resources.working_set
    package_ids = [f"{p.project_name}=={p.version}" for p in packages]
    duplicate_ids = set([x for x in package_ids if package_ids.count(x) > 1])
    return duplicate_ids

def list_duplicates():
    duplicate_packages = find_duplicates()
    if not duplicate_packages:
        print("No packages with duplicate IDs found")
    else:
        print("Packages with duplicate IDs:")
        for package in duplicate_packages:
            print(package)

def remove_duplicates():
    removed_packages = []
    package_ids = set()
    packages = []
    for package in pip.get_installed_distributions():
        if package.project_name.lower() not in package_ids:
            package_ids.add(package.project_name.lower())
            packages.append(package)
        else:
            removed_packages.append(package)
    pip.main(['uninstall', '-y'] + [package.project_name for package in removed_packages])
    if not removed_packages:
        print("No packages with duplicate IDs found")
    else:
        print("Packages with duplicate IDs removed:")
        for package in removed_packages:
            print(package)

def dump_packages():
    installed_packages = pip.get_installed_distributions()
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
        installed_packages = [line.strip() for line in f]
    updated_packages = mpm.update_packages(installed_packages)
    with open(filename, 'w') as f:
        for package in updated_packages:
            f.write(f"{package}\n")
    print("Packages updated successfully!")

def merge_packages():
    previous_dump = input("Enter the name of the previous dump file (including the extension): ")
    current_dump = input("Enter the name of the current dump file (including the extension): ")
    with open(previous_dump, 'r') as f:
        previous_packages = [line.strip() for line in f]
    with open(current_dump, 'r') as f:
        current_packages = [line.strip() for line in f]
    merged_packages = set(previous_packages).union(set(current_packages))
    with open(current_dump, 'w') as f:
        for package in merged_packages:
            f.write(f"{package}\n")
    print("Packages merged successfully!")

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
    
