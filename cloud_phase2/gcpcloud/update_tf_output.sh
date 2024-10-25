#!/bin/bash

# Get IPs from terraform output
MASTER_IP=$(terraform output -raw master)

# Get worker IPs by filtering and extracting with grep and sed
WORKER_IPS=$(terraform output -json worker_IPs)

# Remove brackets and quotes, then extract the IPs
WORKER_IPS=$(echo "$WORKER_IPS" | tr -d '[]"' | tr ',' '\n')

# Extract each worker IP from the formatted output
WORKER1_IP=$(echo "$WORKER_IPS" | grep 'worker1 =' | cut -d' ' -f3)
WORKER2_IP=$(echo "$WORKER_IPS" | grep 'worker2 =' | cut -d' ' -f3)
WORKER3_IP=$(echo "$WORKER_IPS" | grep 'worker3 =' | cut -d' ' -f3)
WORKER4_IP=$(echo "$WORKER_IPS" | grep 'worker4 =' | cut -d' ' -f3)
WORKER5_IP=$(echo "$WORKER_IPS" | grep 'worker5 =' | cut -d' ' -f3)

# Add the new entries to /etc/hosts
sudo echo "Updating /etc/hosts with master and worker IPs..."
sudo echo "$MASTER_IP master" >> /etc/hosts
sudo echo "$WORKER1_IP worker1" >> /etc/hosts
sudo echo "$WORKER2_IP worker2" >> /etc/hosts
sudo echo "$WORKER3_IP worker3" >> /etc/hosts
sudo echo "$WORKER4_IP worker4" >> /etc/hosts
sudo echo "$WORKER5_IP worker5" >> /etc/hosts

# Update Ansible hosts file (gcphosts)
ANSIBLE_HOSTS_FILE="gcphosts"

# Update the IP addresses for the master and worker nodes in the gcphosts file
echo "Updating $ANSIBLE_HOSTS_FILE with new IPs..."

sed -i "s/ansible_host=[0-9.]\+ ansible_user=ubuntu ansible_connection=ssh/ansible_host=$MASTER_IP ansible_user=ubuntu ansible_connection=ssh/g" $ANSIBLE_HOSTS_FILE
sed -i "s/worker1 *ansible_host=[0-9.]\+/worker1        ansible_host=$WORKER1_IP/g" $ANSIBLE_HOSTS_FILE
sed -i "s/worker2 *ansible_host=[0-9.]\+/worker2        ansible_host=$WORKER2_IP/g" $ANSIBLE_HOSTS_FILE
sed -i "s/worker3 *ansible_host=[0-9.]\+/worker3        ansible_host=$WORKER3_IP/g" $ANSIBLE_HOSTS_FILE
sed -i "s/worker4 *ansible_host=[0-9.]\+/worker4        ansible_host=$WORKER4_IP/g" $ANSIBLE_HOSTS_FILE
sed -i "s/worker5 *ansible_host=[0-9.]\+/worker5        ansible_host=$WORKER5_IP/g" $ANSIBLE_HOSTS_FILE
:
echo "Ansible hosts file updated successfully:"
