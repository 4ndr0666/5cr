import argparse
import subprocess

def main():
    parser = argparse.ArgumentParser(description="Wrapper for the Meta Package Manager (mpm)")
    subparsers = parser.add_subparsers()

    parser_install = subparsers.add_parser("install", help="Install a package")
    parser_install.add_argument("package_name", help="Name of the package to install")
    parser_install.set_defaults(func=install_package)

    parser_uninstall = subparsers.add_parser("uninstall", help="Uninstall a package")
    parser_uninstall.add_argument("package_name", help="Name of the package to uninstall")
    parser_uninstall.set_defaults(func=uninstall_package)

    parser_update = subparsers.add_parser("update", help="Update package lists")
    parser_update.set_defaults(func=update_packages)

    parser_upgrade = subparsers.add_parser("upgrade", help="Upgrade all packages")
    parser_upgrade.set_defaults(func=upgrade_packages)

    parser_list = subparsers.add_parser("list", help="List installed packages")
    parser_list.set_defaults(func=list_installed)

    parser_search = subparsers.add_parser("search", help="Search for a package")
    parser_search.add_argument("query", help="Search query")
    parser_search.set_defaults(func=search_package)

    parser_doctor = subparsers.add_parser("doctor", help="Run diagnostic checks")
    parser_doctor.set_defaults(func=doctor)

    args = parser.parse_args()
    if hasattr(args, 'func'):
        args.func(args)
    else:
        parser.print_help()
        exit(1)
    args.func(args)

def install_package(args):
    subprocess.run(["mpm", "install", args.package_name])

def uninstall_package(args):
    subprocess.run(["mpm", "uninstall", args.package_name])

def update_packages(args):
    subprocess.run(["mpm", "update"])

def upgrade_packages(args):
    subprocess.run(["mpm", "upgrade"])

def list_installed(args):
    subprocess.run(["mpm", "list"])

def search_package(args):
    subprocess.run(["mpm", "search", args.query])

def doctor(args):
    subprocess.run(["mpm", "doctor"])

if __name__ == "__main__":
    main()