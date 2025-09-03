#!/bin/bash

# Check if we're in a git repository
default_git_dir=$(git rev-parse --is-inside-work-tree 2>/dev/null)
if [[ -z "$default_git_dir" || "$default_git_dir" != "true" ]]; then
  echo "Error: Not in a git repository. Please run this script from within a git project." >&2
  exit 1
fi

# Define options as an array where each element contains "name|email"
# TODO: Swap this with an .env file or similar. For now this will do.
options=(
  "SimplyMinimal|SimplyMinimal@users.noreply.github.com"
  "WorkUserAccount|alternateworkprofile@example.com"
)

echo "Git User Configuration Selector"
echo "==============================="
echo

echo "Available configurations:"
for i in "${!options[@]}"; do
  # Split the option to display name and email nicely
  IFS='|' read -r name email <<< "${options[$i]}"
  echo "  $((i+1)). Name: $name"
  echo "      Email: $email"
done
echo "  $((${#options[@]}+1)). Exit without changes"
echo

# Present menu and get selection
while true; do
  PS3="Enter your choice (1-${#options[@]}) or $((${#options[@]}+1)) to exit: "
  select opt in "${options[@]}" "Exit without changes"; do
    if [[ -n "$REPLY" && $REPLY -le ${#options[@]} ]]; then
      # Extract name and email from the selected option
      IFS='|' read -r name email <<< "${options[$REPLY-1]}"
      echo -e "\nSetting git config for:\n  Name:   $name\n  Email:  $email"

      if git config --local user.name "$name" && \
         git config --local user.email "$email"; then
        echo -e "\n✓ Git configuration set successfully."
      else
        echo -e "\n✗ Error: Failed to set git config" >&2
        exit 1
      fi

      break 2  # Exit both the inner and outer loop
    elif [[ -n "$REPLY" && $REPLY -eq $((${#options[@]}+1)) ]]; then
      echo -e "\nExiting without changes."
      exit 0
    else
      echo -e "\n✗ Invalid option. Please enter a number between 1 and $((${#options[@]}+1))."
    fi
  done
done

