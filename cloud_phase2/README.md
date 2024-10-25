
# Project Setup

## Deployment

**Initialize management vm**

```bash
vagrant up
```
**Initialize Terraform**
```bash
cd /proj/gcpcloud/
```

**Initialize Terraform**
```bash
terraform init
```

**Generate SSH Key**
```bash
ssh-keygen -t rsa -b 2048
```

**Plan and Apply Deployment**
```bash
terraform plan

terraform apply
```

**Update Terraform Output**
```bash
sudo ./update_tf_output.sh

export ANSIBLE_HOST_KEY_CHECKING=False
```

**Configure GCP Nodes**
```bash
ansible-playbook -i gcphosts ansible-gcp-configure-nodes.yml
```

**Install Kubernetes**
```bash
ansible-playbook -i gcphosts ansible-k8s-install.yml
```

**Create Kubernetes Cluster**
```bash
ansible-playbook -i gcphosts ansible-create-cluster.yml
```

**Join Worker Nodes**
```bash
ansible-playbook -i gcphosts ansible-workers-join.yml
```

**Start Deployment**
We are conducting a \(2^r\) Factorial Design with 6 parameters. The playbooks allow you to adjust the following parameters:

- **Number of Shards:** 3 vs 5
- **Replicas:** On vs Off
- **CPU & RAM:** n1-standard-1 vs n2-standard-4 (Changed directly in the terraform files)
- **Disk Type:** Standard vs Balanced (Changed directly in the terraform files)
- **Request Type:** Readonly vs Writeonly
- **Journaling Commit Interval:** 50ms vs 500ms

The available configurations for deployment are defined in playbooks starting with `ansible-start-deployment`. Here are some examples:

The 50 and 500 in the end stand for the journaling commit interval.

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

gcloud compute ssh --zone "europe-west4-b" "master" --project "<name of project>"
```

After accessing the master node, do the following to be sure the db is fully configured.

```bash
cd /home/ubuntu

sudo ./configure_topology.sh <journaling-commit-interval>

```

## Tests

After deployment, you can run tests to test the system performance and scalability. 
The tests can be run by accessing directly to the mongo-test-client pod.

```bash
sudo kubectl exec -it <nome-do-mongo-test-client-pod> -- bash
```

Once inside the pod, you can run the test files. 
- **There are two available test files**: 

  - `write_client.js`
  - `read_client.js`

To execute the write test, use the following command:
```bash
node write_client.js <num_of_shards> <throughput_in_req/min>
```

The program needs to be manually stopped with ctrl+c seeing the results for the tests
and it will add the throughput and latency to a csv file called **results_write.csv** or **results_read.csv** accordingly.

This can be obtained in the host machine by running the following playbook:

```bash
ansible-playbook -i gcphosts ansible-copy-results.yml
```

### Results
In case there were multiple experiments for the same run, there is a script to do the mean of the run **mean_script.py**
In case the n2-standard-4 machine was used. There will be a client per cpu and therefore 4 different lines in the results.csv. 
**sum_different_4cpus_results.py** will sum these 4 lines of concurrent requests sent to the server and make the average of the latency

Results will be saved in the `results` directory for further analysis.

## Destroying infrastructure

**Delete Deployment**
```bash
ansible-playbook -i gcphosts ansible-delete-deployment.yml
```

**Terraform Destroy**
```bash
terraform destroy
```

Exit the VM with:
```bash
vagrant halt
```

