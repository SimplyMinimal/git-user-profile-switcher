# Git User Profile Switcher

A simple bash script to quickly switch between different git user configurations for local repositories.

## What it does

The `set-git-profile.sh` script allows you to easily switch between predefined git user profiles (name and email) for the current repository. It sets the git configuration locally (repository-specific) rather than globally, so different projects can use different identities.

## Features

- Interactive menu to select from predefined user profiles
- Repository-specific configuration (uses `git config --local`)
- Validates that you're in a git repository before running
- Easy to customize with your own profiles

## Setup

1. Edit the `options` array in `set-git-profile.sh` to include your own git profiles:
   ```bash
   options=(
     "YourName|your.email@example.com"
     "WorkProfile|work.email@company.com"
   )
   ```

2. Make the script executable:
   ```bash
   chmod +x set-git-profile.sh
   ```

## Usage

1. Navigate to any git repository
2. Run the script:
   ```bash
   ./set-git-profile.sh
   ```

3. Select the desired profile from the interactive menu
4. The script will set the local git configuration for that repository

## Example Output

```
Git User Configuration Selector
===============================

Available configurations:
  1. Name: SimplyMinimal
      Email: SimplyMinimal@users.noreply.github.com
  2. Name: WorkUserAccount
      Email: alternateworkprofile@example.com
  3. Exit without changes

Enter your choice (1-2) or 3 to exit: 1

Setting git config for:
  Name:   SimplyMinimal
  Email:  SimplyMinimal@users.noreply.github.com

✓ Git configuration set successfully.
```

## Requirements

- Bash shell
- Git installed and available in PATH
- Must be run from within a git repository

## Notes

- The configuration is set locally for the current repository only
- To make the script available system-wide, consider adding it to your PATH or creating an alias