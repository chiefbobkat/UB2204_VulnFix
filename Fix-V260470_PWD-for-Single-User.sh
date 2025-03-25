#!/bin/bash

# Prompt user for password
echo "Enter password for GRUB superuser (will not be displayed):"
read -s password
echo ""

# Prompt user to confirm the password
echo "Confirm password for GRUB superuser (will not be displayed):"
read -s password_confirm
echo ""

# Verify that the passwords match
if [ "$password" != "$password_confirm" ]; then
    echo "Error: Passwords do not match. Exiting."
    exit 1
fi

# Generate hashed password using grub-mkpasswd-pbkdf2
# Since grub-mkpasswd-pbkdf2 doesn't accept stdin directly, we'll use a workaround
# by echoing the password twice with newlines and piping it to the command.
hashed_password=$(echo -e "$password\n$password" | grub-mkpasswd-pbkdf2)

# Extract the hash from the output
hash=$(echo "$hashed_password" | awk '/grub.pbkdf/{print $NF}')

# Set superuser name
superuser="root"

# Update /etc/grub.d/40_custom with the hashed password
echo "set superusers=\"$superuser\"" >> /etc/grub.d/40_custom
echo "password_pbkdf2 $superuser $hash" >> /etc/grub.d/40_custom

# Run sudo update-grub to apply changes
sudo update-grub
