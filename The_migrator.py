#!/usr/bin/env python3

import os
import subprocess
import sys

# Define header and ask for confirmation
header = """
 _______ _________ _______  _______  _______ _________ _______  _______
(  ____ \\__   __/(  ____ )(  ___  )(  ____ \\__   __/(  ____ )(  ____ \\
| (    \\/   ) (   | (    )|| (   ) || (    \\/   ) (   | (    )|| (    \\/
| (_____    | |   | (____)|| (___) || (__       | |   | (____)|| (__    
(_____  )   | |   |     __)|  ___  ||  __)      | |   |     __)|  __)   
      ) |   | |   | (\ (   | (   ) || (         | |   | (\ (   | (      
/\\____) |___) (___| ) \\ \\__| )   ( || (____/\\___) (___| ) \\ \\__| (____/\\
\\_______)\\_______/|/   \\__/|/     \\|(_______/\\_______/|/   \\__/\\_______/
"""

print(header)
print("This script will migrate the setup of the user 'andro' from /dev/sdc4 to /dev/sda2.")
print("Make sure that both drives are mounted and accessible before proceeding.")
confirm = input("Do you want to continue? (y/n) ")

if confirm != "y":
    sys.exit("Migrator aborted.")

# Define source and destination paths
src_path = "/mnt/sdc4/home/andro"
dst_path = "/mnt/sda2/home/andro"

# Copy files with rsync and verify success
try:
    subprocess.run(["rsync", "-avz", "--progress", "--exclude", ".cache", "--exclude", ".local/share/Trash", src_path, dst_path], check=True)
    print("Migrator: Copy successful.")
except subprocess.CalledProcessError as e:
    sys.exit(f"Migrator: Copy failed with error: {e}")

# Update fstab with new UUID for /dev/sda2
try:
    subprocess.run(["blkid", "/dev/sda2", "-s", "UUID", "-o", "value"], check=True, stdout=subprocess.PIPE)
except subprocess.CalledProcessError as e:
    sys.exit(f"Migrator: Failed to get UUID for /dev/sda2 with error: {e}")
new_uuid = str(stdout.strip(), "utf-8")
fstab_path = "/mnt/sda2/etc/fstab"
try:
    with open(fstab_path, "r+") as f:
        contents = f.read()
        f.seek(0)
        f.truncate()
        for line in contents.split("\n"):
            if "/dev/sda2" in line:
                line = line.replace(line.split(" ")[0], f"UUID={new_uuid}")
            f.write(line + "\n")
    print("Migrator: Updated fstab with new UUID.")
except Exception as e:
    sys.exit(f"Migrator: Failed to update fstab with new UUID with error: {e}")

print("Migrator: Migration complete.")
