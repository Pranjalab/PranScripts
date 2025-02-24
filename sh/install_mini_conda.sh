#!/bin/bash
# This script installs Miniconda system-wide for all users

set -e

# Variables
MINICONDA_INSTALLER=Miniconda3-latest-Linux-x86_64.sh
INSTALLER_URL="https://repo.anaconda.com/miniconda/${MINICONDA_INSTALLER}"
INSTALL_PREFIX="/opt/miniconda"

# Download the installer to /tmp
echo "Downloading Miniconda installer..."
wget "${INSTALLER_URL}" -O "/tmp/${MINICONDA_INSTALLER}"

# Run the installer silently (-b) with the specified prefix (-p)
echo "Installing Miniconda to ${INSTALL_PREFIX}..."
sudo bash "/tmp/${MINICONDA_INSTALLER}" -b -p "${INSTALL_PREFIX}"

# Set permissions so that all users can execute conda commands
echo "Setting permissions for ${INSTALL_PREFIX}..."
sudo chmod -R a+rx "${INSTALL_PREFIX}"

# Create a profile file to add Miniconda to system PATH for all users
echo "Configuring system PATH..."
echo 'export PATH="/opt/miniconda/bin:$PATH"' | sudo tee /etc/profile.d/miniconda.sh

# Clean up the installer
rm "/tmp/${MINICONDA_INSTALLER}"

echo "Miniconda has been installed in ${INSTALL_PREFIX}."
echo "Please re-login or run 'source /etc/profile.d/miniconda.sh' to update your PATH."
