import json
import os
import sys
import subprocess
import pkg_resources
import pip

def print_menu():
    print("Menu")
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

def search(package_name):
    results = pip.search(package_name)
    return results

def install(package_name):
    pip.main(['install', package_name])

def uninstall(package_name):
    pip.main(['uninstall', '-y', package_name])

def list_installed():
    packages = [package.project_name for package in pip.get_installed_distributions()]
    return sorted(packages)

def check_updates():
    outdated = {}
    for dist in pip.get_installed_distributions():
        latest = pip.utils.pypi.get_latest_version(dist.project_name)
        if dist.version != latest:
            outdated[dist.project_name] = latest
    return outdated

def update(package_name):
    pip.main(['install', '-U', package_name])

def upgrade_all():
    pip.main(['install', '-U', 'pip'])
    pip.main(['freeze', '--local', '|', 'grep', '-v', '^\-e', '|', 'cut', '-d', '=', '-f 1', '|', 'xargs', '-n1', 'pip', 'install', '-U'])

def pip_upgrade_all():
    pip.main(['install', '-U', 'pip'])
    pip.main(['list', '--outdated', '--format=freeze', '|', 'grep', '-v', '^\-e', '|', 'cut', '-d', '=', '-f 1', '|', 'xargs', '-n1', 'pip', 'install', '-U'])

def search_exact(package_name):
    results = pip.search(package_name)
    exact_matches = [package for package in results if package_name.lower() == package['name'].lower()]
    return exact_matches

def find_duplicates():
    packages = pip.get_installed_distributions()
    package_ids = {}
    for package in packages:
        package_id = package.project_name.lower()
        if package_id in package_ids:
            package_ids[package_id].append(package.project_name)
        else:
            package_ids[package_id] = [package.project_name]
    duplicate_packages = []
    for package_id, package_names in package_ids.items():
        if len(package_names) > 1:
            duplicate_packages.extend(package_names)
    return duplicate_packages

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
