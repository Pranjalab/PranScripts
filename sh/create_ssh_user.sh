#!/bin/bash

# Check if script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root or with sudo privileges."
  exit 1
fi

# Prompt for the username
read -p "Enter the new username: " username

# Check if the user already exists
if id "$username" &>/dev/null; then
  echo "❌ User '$username' already exists."
  exit 1
fi

# Create a new user
useradd -m -s /bin/bash "$username"
echo "✅ User '$username' created successfully."

# Add the new user to the sudo group
usermod -aG sudo "$username"
echo "✅ User '$username' added to the sudo group."

# Create the .ssh directory and authorized_keys file
user_home="/home/$username"
ssh_dir="$user_home/.ssh"
authorized_keys="$ssh_dir/authorized_keys"

mkdir -p "$ssh_dir"
touch "$authorized_keys"

# Set permissions
chown -R "$username:$username" "$ssh_dir"
chmod 700 "$ssh_dir"
chmod 600 "$authorized_keys"

# Prompt for the SSH public key
read -p "🔑 Paste the public SSH key for the user: " ssh_key
echo "$ssh_key" > "$authorized_keys"

# Ensure correct ownership again
chown "$username:$username" "$authorized_keys"

# SSH Configuration
server_ip=$(hostname -I | awk '{print $1}')

echo "✅ SSH key added successfully."

# Generate a strong random password for the user
# Adjust the length as needed (e.g., 12, 16, 24, etc.)
password=$(openssl rand -base64 16)

# Set the generated password for the user
echo "$username:$password" | chpasswd

# Generate SSH client configuration block
echo -e "\n🔗 Use the following SSH configuration block on your local machine:\n"
echo "-------------------------------------------"
cat <<EOF
Host ${username}-Server
    HostName $server_ip  # Replace with your server's IP if needed
    User $username       # The username on the server

    IdentityFile ~/.ssh/id_rsa    # Path to your private SSH key
    UseKeychain yes               # macOS only - stores passphrase in Keychain
    AddKeysToAgent yes            # Automatically adds SSH key to agent
    IdentitiesOnly yes            # Only use the specified identity file
EOF
echo "-------------------------------------------"

# Print the generated password
echo -e "\n🔐 A strong password has been generated for user '$username':"
echo "-------------------------------------------"
echo "Password: $password"
echo "-------------------------------------------"
echo "🚀 All done! You can now SSH into the server using the config above."
