#!/bin/bash

# Check if we're in a git repository
default_git_dir=$(git rev-parse --is-inside-work-tree 2>/dev/null)
if [[ -z "$default_git_dir" || "$default_git_dir" != "true" ]]; then
  echo "Error: Not in a git repository. Please run this script from within a git project." >&2
  exit 1
fi

# Function to detect available SSH keys
detect_ssh_keys() {
  local ssh_keys=()
  local ssh_dir="$HOME/.ssh"

  # Look for common SSH key patterns
  for key_file in "$ssh_dir"/id_rsa "$ssh_dir"/id_ed25519 "$ssh_dir"/id_ecdsa "$ssh_dir"/id_ed25519_*; do
    if [[ -f "$key_file" && ! "$key_file" == *.pub ]]; then
      ssh_keys+=("$(basename "$key_file")")
    fi
  done

  printf '%s\n' "${ssh_keys[@]}"
}

# Function to configure SSH key for git
configure_ssh_key() {
  local ssh_key="$1"
  local ssh_key_path="$HOME/.ssh/$ssh_key"

  if [[ ! -f "$ssh_key_path" ]]; then
    echo "Warning: SSH key file $ssh_key_path not found" >&2
    return 1
  fi

  # Set the SSH command for git to use the specific key
  git config --local core.sshCommand "ssh -i $ssh_key_path -o IdentitiesOnly=yes"
  return $?
}

# Define options as an array where each element contains "name|email|ssh_key"
# TODO: Swap this with an .env file or similar. For now this will do.
options=(
  "SimplyMinimal|SimplyMinimal@users.noreply.github.com|id_ed25519"
  "WorkUserAccount|alternateworkprofile@example.com|id_rsa"
)

echo "Git User Configuration Selector"
echo "==============================="
echo

# Detect available SSH keys
available_ssh_keys=()
while IFS= read -r key; do
  available_ssh_keys+=("$key")
done < <(detect_ssh_keys)

if [[ ${#available_ssh_keys[@]} -gt 1 ]]; then
  echo "Multiple SSH keys detected: ${available_ssh_keys[*]}"
  echo
fi

echo "Available configurations:"
for i in "${!options[@]}"; do
  # Split the option to display name, email, and SSH key nicely
  IFS='|' read -r name email ssh_key <<< "${options[$i]}"
  echo "  $((i+1)). Name: $name"
  echo "      Email: $email"
  if [[ -n "$ssh_key" ]]; then
    echo "      SSH Key: $ssh_key"
  fi
  echo
done
echo "  $((${#options[@]}+1)). Exit without changes"
echo

# Present menu and get selection
while true; do
  PS3="Enter your choice (1-${#options[@]}) or $((${#options[@]}+1)) to exit: "
  select opt in "${options[@]}" "Exit without changes"; do
    if [[ -n "$REPLY" && $REPLY -le ${#options[@]} ]]; then
      # Extract name, email, and SSH key from the selected option
      IFS='|' read -r name email ssh_key <<< "${options[$REPLY-1]}"
      echo -e "\nSetting git config for:\n  Name:     $name\n  Email:    $email"

      if [[ -n "$ssh_key" ]]; then
        echo "  SSH Key:  $ssh_key"
      fi

      # Set git user configuration
      if git config --local user.name "$name" && \
         git config --local user.email "$email"; then
        echo -e "\n✓ Git user configuration set successfully."
      else
        echo -e "\n✗ Error: Failed to set git user config" >&2
        exit 1
      fi

      # Configure SSH key if specified and multiple keys are available
      if [[ -n "$ssh_key" && ${#available_ssh_keys[@]} -gt 1 ]]; then
        echo -e "\nConfiguring SSH key..."
        if configure_ssh_key "$ssh_key"; then
          echo "✓ SSH key configuration set successfully."
        else
          echo "✗ Warning: Failed to configure SSH key. Git user config was still applied." >&2
        fi
      elif [[ -n "$ssh_key" && ${#available_ssh_keys[@]} -eq 1 ]]; then
        echo -e "\nOnly one SSH key detected. SSH configuration not needed."
      elif [[ ${#available_ssh_keys[@]} -gt 1 ]]; then
        echo -e "\nWarning: Multiple SSH keys detected but no SSH key specified for this profile."
        echo "Consider updating the profile configuration to include an SSH key."
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

