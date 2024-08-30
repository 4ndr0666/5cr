#!/bin/bash -e

. /etc/makepkg.conf

PKGCACHE=$(grep -m 1 '^CacheDir' /etc/pacman.conf | sed 's/CacheDir\s*=\s*//')

pkgdirs=("$@" "$PKGDEST" "$PKGCACHE")

for package in "$@"; do
  package_name=$(echo "$package" | cut -d'-' -f1)
  package_version=$(echo "$package" | cut -d'-' -f2)

  package_path=""
  for pkgdir in "${pkgdirs[@]}"; do
    package_path="$pkgdir/${package_name}-${package_version}-*.pkg.tar.{xz,zst}"
    if [ -f "$package_path" ]; then
      break
    else
      package_path=""
    fi
  done

  if [ -z "$package_path" ]; then
    echo "$package not found, downloading..."
    sudo pacman -S --needed --noconfirm "$package"
  else
    echo "$package found at $package_path"
  fi
done
