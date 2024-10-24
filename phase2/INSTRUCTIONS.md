# Deployment Commands

This document contains essential commands for managing your deployment using Terraform and Ansible.

## Follow these commands

```bash
vagrant up
```

Inside the VM, navigate to the project directory:

```bash
cd proj/gcpcloud
```

### 1. Initialize Terraform
Initialize the Terraform configuration.
```bash
terraform init
```

### 2. Generate SSH Key
Generate a new RSA SSH key pair.
```bash
ssh-keygen -t rsa -b 2048
```

### 3. Plan Deployment
Generate an execution plan for Terraform.
```bash
terraform plan
```

### 4. Apply Deployment
Apply the planned changes to your infrastructure.
```bash
terraform apply
```

### 5. Update Terraform Output
Run a script to update Terraform output values.
```bash
sudo ./update_tf_output.sh

export ANSIBLE_HOST_KEY_CHECKING=False
```

### 6. Configure GCP Nodes
Run the playbook to configure Google Cloud Platform nodes.
```bash
ansible-playbook -i gcphosts ansible-gcp-configure-nodes.yml
```

### 7. Install Kubernetes
Run the playbook to install Kubernetes on the nodes.
```bash
ansible-playbook -i gcphosts ansible-k8s-install.yml
```

### 8. Create Kubernetes Cluster
Run the playbook to create a Kubernetes cluster.
```bash
ansible-playbook -i gcphosts ansible-create-cluster.yml
```

### 9. Join Worker Nodes
Run the playbook to join worker nodes to the cluster.
```bash
ansible-playbook -i gcphosts ansible-workers-join.yml
```

### 10. Start Deployment
To start the deployment, run one of the following playbooks:
```bash
ansible-playbook -i gcphosts ansible-start-deployment.yml
```

### 11. Delete Deployment
To delete the deployment, run one of the following playbooks:
```bash
ansible-playbook -i gcphosts ansible-delete-deployment.yml
```
To go inside the master, go to the Google Cloud Console and copy the gcloud command, which should look something like this:

```bash
gcloud compute ssh --zone "europe-west4-b" "master" --project "agisit-2425-website-99970"
```

### 12. Terraform Destroy
```bash
terraform destroy
```

Leave the VM and do the following command:
```bash
vagrant halt
```
