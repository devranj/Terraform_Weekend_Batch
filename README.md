# Terraform Weekend Batch

This repository contains Terraform code designed for weekend training sessions or bootcamps focused on Infrastructure as Code (IaC) using Terraform. It is structured for learners who want hands-on experience with provisioning and managing cloud infrastructure.

## 📚 What You'll Learn

- Basics of Terraform (init, plan, apply, destroy)
- Provider configuration (e.g., AWS)
- Resource creation (e.g., EC2, VPC, S3)
- Variables, Outputs, and Modules
- State management and backend configuration
- Best practices in Terraform code structure

## 🏗️ Project Structure

```

Terraform\_Weekend\_Batch/
├── modules/
│   └── <modularized-resources>
├── environments/
│   ├── dev/
│   └── prod/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md

````

## 🛠️ Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0.0
- An active cloud account (e.g., AWS)
- AWS CLI configured with credentials (if using AWS)
  ```bash
  aws configure
````

## 🚀 Getting Started

1. Clone the repository:

   ```bash
   git clone https://github.com/your-org/Terraform_Weekend_Batch.git
   cd Terraform_Weekend_Batch
   ```

2. Initialize Terraform:

   ```bash
   terraform init
   ```

3. Review the execution plan:

   ```bash
   terraform plan
   ```

4. Apply the configuration:

   ```bash
   terraform apply
   ```

5. Destroy the infrastructure (when done):

   ```bash
   terraform destroy
   ```

## 🧪 Sample Exercises

* Provision a basic EC2 instance
* Create a VPC with public and private subnets
* Launch a 3-tier application using modules
* Manage remote state using S3 and DynamoDB

## 👥 Target Audience

This repository is intended for:

* Weekend learners and professionals
* DevOps trainees
* Developers exploring Infrastructure as Code

## 📄 License

This project is licensed under the MIT License.

---

Feel free to fork, customize, and use this as a base for your own Terraform learning journey!

```

---

Would you like me to tailor it for AWS specifically, or another provider? Or should I adjust it based on your actual file structure?
```
