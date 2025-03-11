# Terraform Azure Project

This project provisions a single small instance on Azure using Terraform. The resources are prefixed with your name, and an SSH key is used for secure access.

## Project Structure

- `main.tf`: Contains the main configuration for provisioning Azure resources.
- `variables.tf`: Defines input variables for customization.
- `outputs.tf`: Specifies outputs such as the public IP address of the virtual machine.
- `provider.tf`: Configures the Azure provider with necessary credentials.
- `README.md`: Documentation for the project.

## Getting Started

### Prerequisites

- Install Terraform: [Terraform Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- Azure account: [Create an Azure account](https://azure.microsoft.com/en-us/free/)

### Initialize Terraform

Run the following command to initialize the Terraform project:

```bash
terraform init
```

### Apply the Configuration

To provision the resources, run:

```bash
terraform apply
```

Review the plan and type `yes` to confirm.

### Log In to the Instance

Once the resources are provisioned, you can log in to the virtual machine using SSH:

```bash
ssh -i /path/to/your/ssh/key username@<public_ip_address>
```

Replace `/path/to/your/ssh/key` with the path to your SSH key and `<public_ip_address>` with the output from `terraform output`.

### Modify a Property

To modify a property (e.g., instance size), update the relevant variable in `variables.tf` and save the changes.

### Re-apply the Configuration

After modifying properties, re-apply the configuration to detect and fix any drift:

```bash
terraform apply
```

### Delete All Resources

To clean up and delete all resources created by Terraform, run:

```bash
terraform destroy
```

Type `yes` to confirm the deletion.

## Notes

- Ensure your SSH key has the correct permissions.
- Review the outputs after applying the configuration for important information.