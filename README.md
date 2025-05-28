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
- 📁 Process entire folders full of packages
- 🖱️ Right-click support via Quick Action (macOS Services)
- ⚡ Fast mode by default (skip verification for speed)

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
- Install a Quick Action for right-click functionality

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
- Remove the Quick Action from macOS Services
- Note: PATH entries in shell config are left unchanged for safety

### Usage

After installation, you have several ways to use PKGFlow:

#### Interactive Mode (Current Directory)
```bash
pkgflow
```

#### Process a Specific Folder
```bash
pkgflow /path/to/folder
```

#### Install a Single Package
```bash
pkgflow MyApp.pkg
pkgflow MyApp.dmg
```

#### Right-Click Installation
After installation, you can right-click any `.pkg`, `.dmg` file, or folder in Finder and select "Install with PKGFlow" from the Quick Actions menu.

#### Advanced Options
```bash
# Enable package verification (slower but safer)
pkgflow --verify MyApp.pkg

# Install to custom location
pkgflow --target /Applications MyApp.pkg
```

Or, if you haven't installed it yet, run it directly:
```bash
./pkgflow.sh
```

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
- Package verification is disabled by default for speed (use `--verify` to enable)
- When processing folders, you'll see the interactive selection menu
- Quick Action may need to be enabled in System Settings > Extensions > Finder

## Quick Action Setup

If the Quick Action doesn't appear after installation:
1. Open System Settings
2. Go to Extensions > Finder
3. Enable "Install with PKGFlow"
4. The option should now appear when right-clicking `.pkg` files, `.dmg` files, or folders

## About

Made with ❤️ by madebycm, 2025

Happy installing! 🎉