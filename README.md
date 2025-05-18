# PKGFlow 📦

Hey there! Welcome to PKGFlow - your friendly macOS package installer that makes installing multiple `.pkg` files a breeze.

## What's PKGFlow?

PKGFlow is a handy command-line tool that helps you install multiple macOS packages at once. Whether you have `.dmg` files with installers inside them, or standalone `.pkg` files, PKGFlow's got you covered! 

We originally built this to make installing VST plugins easier, but it works great for any macOS packages.

## What Can It Do?

- 🎯 Works with both `.dmg` files and `.pkg` files
- 📦 Automatically finds and extracts packages from DMG files
- ✅ Let's you pick and choose which packages to install
- 🚀 Installs multiple packages in one go
- 🧹 Cleans up after itself (no leftover mounted volumes!)

## Getting Started

### Installation

To install PKGFlow globally so you can use it from anywhere:

```bash
./pkgflow.sh --install
```

This will:
- Copy the script to `~/.local/bin/pkgflow`
- Add `~/.local/bin` to your PATH (if needed)
- Make the `pkgflow` command available anywhere

### Uninstallation

To uninstall PKGFlow:

```bash
./pkgflow.sh --uninstall
```

Or if you've already installed it:

```bash
pkgflow --uninstall
```

This will:
- Remove the `pkgflow` command from `~/.local/bin`
- Note: PATH entries in shell config are left unchanged for safety

### Usage

After installation, you can run PKGFlow from any directory:
```bash
pkgflow
```

Or, if you haven't installed it yet, run it directly:
```bash
./pkgflow.sh
```

That's it! PKGFlow will find all the installable packages in your current directory and show you a nice menu.

## What You'll See

Here's what the interface looks like:

```
Package Selection:
==================
1. [X] Shadow_Hills_Mastering_Compressor_Shadow Hills Mastering Compressor Installer.pkg (from DMG)
2. [X] Scaler 3_Scaler 3 Installer.pkg (from DMG)
3. [ ] Some_Other_Package.pkg
4. [X] ADPTR_Hype_ADPTR Hype Installer.pkg (from DMG)

Options:
  Enter package number to toggle selection
  'a' to select all
  'n' to deselect all
  'i' to install selected packages
  'q' to quit

Choice: 
```

## How to Use It

- **Type a number**: Toggle that package on/off
- **Type 'a'**: Select everything
- **Type 'n'**: Deselect everything
- **Type 'i'**: Install your selected packages
- **Type 'q'**: Exit without installing

## What You'll Need

- A Mac (obviously! 😄)
- Admin password (for installing packages)
- Some `.dmg` or `.pkg` files to install

## Behind the Scenes

Here's what PKGFlow does for you:

1. Looks for `.dmg` and `.pkg` files in your current directory
2. Mounts any DMG files it finds
3. Extracts the `.pkg` installers from inside
4. Shows you all available packages in one neat list
5. Installs your selections using macOS's built-in installer
6. Cleans everything up when done

## Good to Know

- Packages from DMG files show "(from DMG)" in the list
- You'll need to enter your admin password when installing
- Selected packages have an `[X]` next to them
- Everything gets cleaned up automatically - no manual unmounting needed!

## About

Made with ❤️ by madebycm, 2025

Happy installing! 🎉