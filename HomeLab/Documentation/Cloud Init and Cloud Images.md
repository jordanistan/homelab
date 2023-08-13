# Cloud Init and Cloud Images

## Introduction

Cloud Init is a standard Linux package that facilitates the initialization of virtual machine instances. When using cloud images along with Cloud Init, it becomes easy to provision Linux machines in cloud environments. Cloud images are minimal, customized images of Linux designed to run in public clouds like AWS, Google Cloud, Azure, OpenStack, and more. These images are certified and optimized for cloud environments, and they come pre-installed with Cloud Init, ready to be configured.

This README provides a guide on how to configure a virtual machine in Proxmox to use a cloud image and Cloud Init. By configuring Cloud Init on the virtual machine, you can bootstrap the machine with your desired settings, such as network configurations and SSH keys, before it is created. Additionally, you can create a template from this configured machine, simplifying the provisioning process for future deployments.

## Prerequisites

- Access to a Proxmox server
- Basic familiarity with Proxmox and virtual machine management
- Knowledge of SSH and basic Linux commands

## Step 1: Downloading the Cloud Image

1. Go to the repository where the cloud images are hosted (e.g., Ubuntu cloud images repository).
2. Download the desired cloud image. For example, you can download the "focal server cloud image" for Ubuntu.
3. Copy the download link of the image to your clipboard.

## Step 2: Configuring the Virtual Machine

1. SSH into your Proxmox server.
2. Use the `wget` command to download the cloud image using the link copied in the previous step.
3. Create a virtual machine using the `qm create` command. Choose a suitable ID, set the memory size, and provide a name for the virtual machine. Also, specify the networking settings using the `--netX` options (e.g., `--net0 virtio,bridge=vmbr0`).
4. Import the downloaded cloud image as a disk for the virtual machine using the `qm importdisk` command. Specify the target storage location (e.g., `local-lvm`) and the path to the cloud image.
5. Attach the imported disk to the virtual machine using the `qm set` command. Specify the SCSI hardware settings and the path to the imported disk.

## Step 3: Configuring Cloud Init Drive

1. Access the Proxmox GUI and navigate to the virtual machine's options.
2. Click on the "Hardware" tab and add a "CD/DVD Drive" using the "Add" button.
3. In the "CD/DVD Drive" settings, choose "Cloud Init Drive" as the "ISO Image" and set the "Bus/Device" to `ide2`.
4. Enable the "Serial Console" in the virtual machine settings to view the terminal output through the webVNC console.

## Step 4: Configuring Cloud Init Settings

1. In the Proxmox GUI, go to the "Options" tab of the virtual machine and click on "Cloud Init".
2. Configure the desired settings for the virtual machine, such as network settings, SSH keys, user accounts, and more.
3. Make sure to set at least the networking configuration to DHCP or specify the desired static IP address if needed.
4. Save the settings.

## Step 5: Creating a Template

1. Right-click on the virtual machine in the Proxmox GUI and select "Convert to Template".
2. Confirm the conversion to a template. This step is irreversible.
3. The template will now be available for cloning and creating new instances.

## Step 6: Cloning a Machine

1. Right-click on the template in the Proxmox GUI and select "Clone".
2. Specify the details for the new clone, such as the name, resource pool, and target storage.
3. Choose the cloning mode (e.g., full clone) and click "Clone".
4. The cloned machine will be created with the configured Cloud Init settings, ready for use.

## Troubleshooting

- If multiple machines have the same IP address, it indicates that the machine ID or UUID is the same across those machines. To resolve this, follow the instructions in the provided documentation to reset the machine ID and UUID.
- Avoid starting up the base image after creating the template to prevent multiple machines with the same identity.

## Conclusion

Cloud Init and cloud images offer an efficient way to provision Linux machines in cloud environments. By configuring Cloud Init on a virtual machine and creating a template, you can easily replicate and deploy new instances with the desired settings. This README has provided step-by-step instructions to help you configure a virtual machine with a cloud image and Cloud Init in Proxmox.