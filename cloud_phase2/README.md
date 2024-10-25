
# Project Setup

## Deployment

### Initialize management vm

```bash
vagrant up
```

### 1. Initialize Terraform
```bash
cd /proj/gcpcloud
```

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Generate SSH Key
```bash
ssh-keygen -t rsa -b 2048
```

### 3. Plan and Apply Deployment
```bash
terraform plan
terraform apply
```

### 5. Update Terraform Output
```bash
sudo ./update_tf_output.sh

export ANSIBLE_HOST_KEY_CHECKING=False
```

### 6. Configure GCP Nodes
```bash
ansible-playbook -i gcphosts ansible-gcp-configure-nodes.yml
```

### 7. Install Kubernetes
```bash
ansible-playbook -i gcphosts ansible-k8s-install.yml
```

### 8. Create Kubernetes Cluster
```bash
ansible-playbook -i gcphosts ansible-create-cluster.yml
```

### 9. Join Worker Nodes
```bash
ansible-playbook -i gcphosts ansible-workers-join.yml
```

### 10. Start Deployment
To start the deployment, you can use various configurations defined in playbooks starting with `ansible-start-deployment`. The following configurations are available:

- **3 Shards without Replication:** 
  - `ansible-start-deployment_3shard_norepl_500.yml`
  - `ansible-start-deployment_3shard_norepl_50.yml`

- **3 Shards with Replication:** 
  - `ansible-start-deployment_3shard_repl_500.yml` 
  - `ansible-start-deployment_3shard_repl_50.yml`

- **5 Shards without Replication:** 
  - `ansible-start-deployment_5shard_norepl_500.yml` 
  - `ansible-start-deployment_5shard_norepl_50.yml`

- **5 Shards with Replication:** 
  - `ansible-start-deployment_5shard_repl_500.yml` 
  - `ansible-start-deployment_5shard_repl_50.yml`

Choose the appropriate playbook based on your deployment requirements.

```bash
ansible-playbook -i gcphosts ansible-start-deployment_3shard_norepl_500.yml  # Example command
```

To access the master node, login to GCP and use the following command :

```bash
gcloud auth login

gcloud compute ssh --zone "europe-west4-b" "master" --project "agisit-2425-website-99970"
```

### 11. Delete Deployment
```bash
ansible-playbook -i gcphosts ansible-delete-deployment.yml
```


### 12. Terraform Destroy
```bash
terraform destroy
```

Exit the VM with:
```bash
vagrant halt
```

## Tests

After deployment, you can run tests to ensure everything is functioning as expected.

### Generating Results
To generate and view the results of your tests, execute the following command:

```bash
# Command to run tests (replace with your actual test command)
./run-tests.sh
```

Results will be saved in the `results/` directory for further analysis.