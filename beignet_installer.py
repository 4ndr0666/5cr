#!/usr/bin/python3

import subprocess
import os

def check_llvm_installation():
    """
    Verifies if LLVM is installed and reports the version.
    """
    try:
        llvm_version = subprocess.check_output(["llvm-config", "--version"], text=True).strip()
        print(f"LLVM Version installed: {llvm_version}")
    except subprocess.CalledProcessError as e:
        print("LLVM is not installed. Please install LLVM. Error:", e)

def verify_llvm_version_compatibility(required_version="7.0.1"):
    """
    Checks if the installed LLVM version is compatible with `beignet`.
    """
    try:
        installed_version = subprocess.check_output(["llvm-config", "--version"], text=True).strip()
        if installed_version.startswith(required_version):
            print(f"LLVM version {installed_version} is compatible with beignet.")
        else:
            print(f"LLVM version {installed_version} is not compatible with beignet. Required version: {required_version}")
    except subprocess.CalledProcessError as e:
        print("Error checking LLVM version:", e)

def install_dependencies(dependencies=["llvm", "clang"]):
    """
    Installs or verifies all required dependencies for `beignet`.
    """
    for dep in dependencies:
        subprocess.run(["sudo", "pacman", "-S", "--needed", dep], check=True)
        print(f"{dep} dependency checked/installed.")

def specify_llvm_config(llvm_config_path="/usr/bin/llvm-config-7"):
    """
    Allows specifying a different `llvm-config` if multiple LLVM versions are installed.
    """
    os.environ["LLVM_CONFIG"] = llvm_config_path
    print(f"LLVM_CONFIG set to {llvm_config_path}")

def review_cmakelists(file_path="CMakeLists.txt"):
    """
    Reviews `CMakeLists.txt` for potential issues by checking for the presence of essential configurations.
    """
    try:
        with open(file_path, 'r') as file:
            contents = file.read()
            if "llvm-config" in contents:
                print(f"`llvm-config` found in {file_path}. Ensure it's correctly configured for your system.")
            else:
                print(f"Review {file_path} for required configurations, `llvm-config` not found.")
    except FileNotFoundError:
        print(f"{file_path} not found, ensure it's in the correct path.")

def clean_build_directory(build_dir):
    """
    Cleans the build directory for a fresh build attempt.
    """
    if os.path.exists(build_dir):
        subprocess.run(["rm", "-rf", build_dir])
        print(f"Cleaned build directory: {build_dir}")
    else:
        print(f"Build directory {build_dir} does not exist, skipping clean.")

def consult_arch_wiki_and_aur_comments():
    """
    Advises on consulting the Arch Wiki and AUR comments for troubleshooting tips.
    """
    print("Manually check the Arch Wiki and AUR comments for `beignet` installation issues and solutions.")

def manual_compilation():
    """
    Provides guidance for manual compilation and installation of `beignet` from source.
    """
    print("Follow the official `beignet` documentation for manual compilation and installation instructions.")

def main():
    check_llvm_installation()
    verify_llvm_version_compatibility()
    install_dependencies()
    specify_llvm_config()
    review_cmakelists()
    clean_build_directory("/path/to/build_dir")
    consult_arch_wiki_and_aur_comments()
    manual_compilation()

if __name__ == "__main__":
    main()
