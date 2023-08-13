# Automated Installation of k3s with HA using Ansible

This README provides instructions on how to install k3s, a lightweight Kubernetes distribution, with high availability (HA) on Proxmox using Ansible, a popular infrastructure automation tool. The goal is to automate the entire process, making it easier and more repeatable.

## Introduction

Setting up k3s with HA manually can be complex and time-consuming. It often involves configuring load balancers, setting up keepalived, and managing multiple components. This automated approach aims to simplify the installation process and eliminate manual steps, making it easier for users to deploy and manage their k3s clusters.

## Prerequisites

Before getting started, ensure you have the following:

- Ansible installed on your control machine.
- Access to Proxmox virtual machines (VMs) for deploying the k3s cluster.
- Basic familiarity with Proxmox and Ansible concepts.

## Step 1: Setting up the Ansible Control Machine

1. Install Ansible on your control machine by following the official documentation: [Ansible Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/index.html).
2. Create an Ansible inventory file (e.g., `inventory.ini`) that lists the VMs' details where you want to deploy the k3s cluster. Example content:
   ```ini
   [k3s_nodes]
   node1 ansible_host=<Proxmox_node_IP> ansible_user=<Proxmox_node_user> ansible_ssh_private_key_file=<path_to_private_key>
   node2 ansible_host=<Proxmox_node_IP> ansible_user=<Proxmox_node_user> ansible_ssh_private_key_file=<path_to_private_key>
   node3 ansible_host=<Proxmox_node_IP> ansible_user=<Proxmox_node_user> ansible_ssh_private_key_file=<path_to_private_key>
   ```
   Replace `<Proxmox_node_IP>`, `<Proxmox_node_user>`, and `<path_to_private_key>` with the actual details of your Proxmox VMs.
3. Ensure that you can SSH into the Proxmox VMs from your control machine without requiring a password. You can set up SSH key-based authentication or provide the necessary credentials within your Ansible inventory.

## Step 2: Creating the Ansible Playbook

1. Create a new directory for your Ansible playbook (e.g., `k3s-ha-playbook`).
2. Navigate to the newly created directory and create a new playbook file (e.g., `install_k3s.yml`).
3. Open the playbook file in a text editor and add the following content:

```yaml
---
- name: Install and configure k3s cluster with HA
  hosts: k3s_nodes
  become: true
  vars:
    k3s_version: <k3s_version>
    kube_vip_version: <kube_vip_version>
    metal_lb_version: <metal_lb_version>
    lb_range_start: <load_balancer_range_start>
    lb_range_end: <load_balancer_range_end>
  tasks:
    - name: Install required packages
      apt:
        name:
          - curl
          - jq
        state: present

    - name: Install k3s
      command: curl -sfL https://get.k3s.io | sh -s - server --cluster-init
      when: inventory_hostname == 'node1'

    - name: Join worker nodes to the cluster
      command: curl -sfL https://get.k3s.io | sh -s - server --server https://{{ hostvars['node1']['ansible_host'] }}:6443
      when: inventory_hostname != 'node1'

    - name: Install kube-vip
      command: curl -sfL https://github.com/kube-vip/kube-vip/releases/download/{{ kube_vip_version }}/kube-vip_{{ kube_vip_version }}_linux_amd64.tar.gz | tar -zxvf - --strip-components=2 -C /usr/local/bin kube-vip
      register: kube_vip_install
      when: inventory_hostname == 'node1'

    - name: Configure kube-vip service
      template:
        src: kube-vip.service.j2
        dest: /etc/systemd/system/kube-vip.service
      when: kube_vip_install is changed

    - name: Start kube-vip service
      service:
        name: kube-vip
        state: started
        enabled: true
      when: kube_vip_install is changed

    - name: Install MetalLB
      shell: kubectl apply -f https://github.com/metallb/metallb/raw/{{ metal_lb_version }}/manifests/metallb.yaml
      when: inventory_hostname == 'node1'

    - name: Configure MetalLB
      template:
        src: metallb-configmap.yml.j2
        dest: metallb-configmap.yml
      when: inventory_hostname == 'node1'

    - name: Apply MetalLB configuration
      shell: kubectl apply -f metallb-configmap.yml
      when: inventory_hostname == 'node1'
```

4. Replace the placeholders `<k3s_version>`, `<kube_vip_version>`, `<metal_lb_version>`, `<load_balancer_range_start>`, and `<load_balancer_range_end>` with the desired versions and load balancer range for your setup.
5. Save the playbook file.

## Step 3: Configuring Templates

1. In the same directory as your playbook, create two template files: `kube-vip.service.j2` and `metallb-configmap.yml.j2`.
2. Open `kube-vip.service.j2` in a text editor and add the following content:

```text
[Unit]
Description=kube-vip service
Documentation=https://kube-vip.io

[Service]
ExecStart=/usr/local/bin/kube-vip start --interface=enp0s3 --vip=192.168.30.80
Restart=on-failure
User=root

[Install]
WantedBy=default.target
```

3. Save the file.

4. Open `metallb-configmap.yml.j2` in a text editor and add the following content:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - {{ lb_range_start }}-{{ lb_range_end }}
```

5. Save the file.

## Step 4: Running the Ansible Playbook

1. Open a terminal and navigate to the directory where you created the playbook (`k3s-ha-playbook`).
2. Execute the following command to run the Ansible playbook and install k3s:

```bash
ansible-playbook -i inventory.ini install_k3s.yml
```

3. Ansible will connect to the Proxmox VMs and execute the playbook tasks, installing k3s on the master node (`node1`) and joining the worker nodes to the cluster. It will also install kube-vip and MetalLB for HA and service load balancing.
4. Once the playbook execution completes successfully, you will have a k3s cluster with high availability running on your Proxmox VMs.

## Verifying the Cluster

To

verify the cluster's status, you can SSH into the master node (`node1`) and use the `kubectl` command-line tool to interact with the cluster:

1. SSH into the master node:
   ```bash
   ssh <Proxmox_node_user>@<Proxmox_node_IP>
   ```

2. Run the following command to check the cluster nodes:
   ```bash
   sudo kubectl get nodes
   ```

   You should see the master node and worker nodes listed as Ready.

3. Run the following command to check the running pods in the cluster:
   ```bash
   sudo kubectl get pods --all-namespaces
   ```

   You should see the pods running in the cluster.

## Conclusion

Congratulations! You have successfully automated the installation of a k3s cluster with high availability on Proxmox using Ansible. This automated approach simplifies the setup process and ensures repeatability. You can now deploy and manage applications on your k3s cluster with ease. Remember to refer to the k3s and Ansible documentation for more advanced configurations and options.

**Note:** This README assumes a basic setup for a development or testing environment. For production deployments, consider additional security measures, such as securing your cluster communication, enabling RBAC, and configuring appropriate networking and storage options.