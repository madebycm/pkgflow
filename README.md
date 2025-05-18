# PKG Installer

A command-line tool for extracting and installing `.pkg` files from DMG images on macOS.

Initially built to help install VST plugins, but works with any DMG containing `.pkg` installers, or simply pure `.pkg` files.

## Features

- Automatically mounts DMG files and extracts `.pkg` installers
- Interactive selection of packages to install
- Supports multiple DMG processing in a single session
- Shows package verification status
- Multi-platform architecture support

## Usage

```bash
./pkg_installer.sh
```

## Example Output

```
Package Selection:
==================
1. [X] Shadow_Hills_Mastering_Compressor_Shadow Hills Mastering Compressor Installer.pkg (from DMG)
2. [X] Scaler 3_Scaler 3 Installer.pkg (from DMG)
3. [X] Mastering_Compressor_Bettermaker Mastering Compressor Installer.pkg (from DMG)
4. [X] ADPTR_Hype_ADPTR Hype Installer.pkg (from DMG)

Options:
  Enter package number to toggle selection
  'a' to select all
  'n' to deselect all
  'i' to install selected packages
  'q' to quit

Choice: 
```

## Options

- **Package number**: Toggle selection of a specific package
- **'a'**: Select all packages
- **'n'**: Deselect all packages
- **'i'**: Install selected packages
- **'q'**: Quit the program

## Requirements

- macOS
- Administrative privileges (for package installation)
- DMG files containing `.pkg` installers

## How It Works

1. The script searches for DMG files in the current directory
2. Mounts each DMG file temporarily
3. Extracts `.pkg` files from mounted volumes
4. Presents an interactive menu for package selection
5. Installs selected packages using the system installer
6. Cleans up by unmounting DMG files and removing temporary files

## Notes

- All packages are marked as "Unverified" when extracted from DMG files
- Installation requires sudo privileges
- Selected packages are marked with `[X]` in the interface
- The script creates a temporary extraction directory that is cleaned up after use