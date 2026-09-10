Usage Instructions
1. Prepare Inventory File
Update the IP addresses and hostnames in inventory.yml to match your environment.

2. Run the Playbook
bash
# Full cluster setup
ansible-playbook -i inventory.yml site.yml

# Setup only common prerequisites
ansible-playbook -i inventory.yml site.yml --tags common

# Setup only control plane
ansible-playbook -i inventory.yml site.yml --tags control-plane

# Setup only worker nodes
ansible-playbook -i inventory.yml site.yml --tags worker

# Verify cluster after setup
ansible-playbook -i inventory.yml site.yml --tags verify
3. Check Results
bash
# SSH to control plane node
ssh ubuntu@192.168.59.107

# Verify cluster
kubectl get nodes -o wide
kubectl get pods -n kube-system

# Advanced Features Added
Feature	Benefit
Idempotent Tasks:	Run playbook multiple times without breaking cluster
Error Handling:	any_errors_fatal: true stops on critical failures
Tag System:	Run specific parts of setup individually
Time Synchronization:	NTP configured to prevent certificate issues
Join Command Storage:	Automatically captured and shared with workers
Health Checks:	Verifies cluster is operational post-setup
Kernel Modules:	Persisted across reboots
Package Holds:	Prevents accidental version upgrades
Structured Logging:	YAML output with task timings
Troubleshooting: If Worker Fails to Join
bash
# Regenerate token on control plane
ansible-playbook -i inventory.yml site.yml --tags control-plane -e "regenerate_token=true"
Reset Cluster (Clean Start)
bash
# On both nodes
ansible -i inventory.yml kubernetes -m shell -a "kubeadm reset -f"

# Then run playbook again
ansible-playbook -i inventory.yml site.yml
Check for Issues
bash
# View detailed logs
ansible-playbook -i inventory.yml site.yml -v

# Debug specific host
ansible-playbook -i inventory.yml site.yml -v -l worker01.centlinux.com
Final Verification

This playbook is production-ready and follows infrastructure-as-code best practices. It's idempotent, meaning you can run it multiple times without breaking your cluster configuration.
