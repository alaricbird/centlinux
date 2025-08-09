# Code for: How to install Terraform on Rocky Linux 10

🔗 **Related Blog Post:** [Read the full article here](https://centlinux.com/install-terraform-on-rocky-linux-10/)
🔗 **Related Vlog Video:** [Watch Complete Video](https://youtu.be/ML2ftaJUR3M)

## 📌 Description
This folder contains the code and configuration files used in the blog post above.

## 📂 Files
- `main.tf` → This is where you declare the actual resources you want Terraform to create — EC2 instances, S3 buckets, VPCs, etc.
- `outputs.tf` → Defines what information Terraform should show you after it finishes building.
- `variables.tf` → Declares input variables so you can easily customize your Terraform without editing the main code.

## 🚀 Usage
1. Clone the repository or download this folder.
2. Install dependencies:
   ```Bash
