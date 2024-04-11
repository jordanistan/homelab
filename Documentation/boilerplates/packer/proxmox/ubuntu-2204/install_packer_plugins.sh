#!/bin/bash

# Define the directory where Packer plugins should be installed
PACKER_PLUGIN_DIR="${HOME}/.packer.d/plugins"

# Ensure the plugin directory exists
mkdir -p "${PACKER_PLUGIN_DIR}"

# Function to install a plugin
install_plugin() {
    local plugin_url="$1"
    local plugin_name="$2"

    # Download the plugin
    curl -L "${plugin_url}" -o "${PACKER_PLUGIN_DIR}/${plugin_name}"

    # Make the plugin executable
    chmod +x "${PACKER_PLUGIN_DIR}/${plugin_name}"
}

# Example usage
# install_plugin "https://path-to-plugin-binary.com/plugin-name" "packer-builder-plugin-name"

# Uncomment the above line and replace with the appropriate URL and plugin name

echo "Done installing plugins!"
