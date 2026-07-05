# A Secure, NIST-Aligned Azure Environment with Terraform 
A hands-on Azure project designed to move beyond “I know the concepts” into “I can actually build, secure, validate, and destroy a real environment from code.”

This project walks through the creation of a secure Azure lab using Terraform, with a strong focus on cloud administration fundamentals, least privilege, governance, and practical security controls. It is built for cloud engineers coming from AWS, people closing the Azure gap, and anyone who wants a project that feels more realistic than a basic VM demo.

> **What you’ll have at the end:** a segmented Azure network, a hardened Linux VM with auto-shutdown, encrypted storage, a Key Vault with RBAC-scoped access, and subscription-level compliance visibility tied to NIST-style governance thinking.
>
> **Who this is for:** cloud admins, Terraform users, AWS engineers transitioning into Azure, and security-minded builders who want a more operational project.
>
> **Time:** 8–12 hours if you are learning as you go.
>
> **Cost:** small lab cost if you clean up afterward.

---

## Why I built this

I built this project because I wanted more hands-on experience with Azure.

I learn best by building, so instead of only reading about Azure services or watching videos, I wanted to create a real environment from code and understand how the pieces work together. This project helped me practice Terraform, Azure networking, Linux VM deployment, storage, identity, and security in a practical way.

My goal was to build something simple enough to learn from, but structured enough to reflect real cloud administration work. It helped me get more comfortable with Azure by doing, testing, and documenting the process from start to finish.

---

## What this project covers

This lab deploys and demonstrates:

- A dedicated Azure resource group.
- A segmented virtual network with separate subnets.
- A hardened Linux VM using SSH keys only.
- Network security groups with least-privilege access.
- A storage account configured for secure access.
- An Azure Key Vault using RBAC.
- Managed identity for secret retrieval without storing credentials locally.
- Policy-driven governance and compliance visibility.
- Infrastructure-as-code deployment and teardown with Terraform.

---

## Architecture

```text
Azure Subscription
└── NIST SP 800-53 Rev. 5 Policy Initiative
    └── Resource Group: rg-azlab-dev
        ├── VNet: 10.10.0.0/16
        │   ├── snet-app:  10.10.1.0/24
        │   │   └── Linux VM
        │   │       ├── SSH keys only
        │   │       ├── Managed identity
        │   │       └── Auto-shutdown enabled
        │   └── snet-data: 10.10.2.0/24
        ├── NSG for least-privilege access
        ├── Storage Account
        │   ├── HTTPS only
        │   ├── TLS 1.2+
        │   └── Public access disabled
        └── Key Vault
            ├── RBAC permission model
            ├── Admin role for operator
            └── Secret read access for VM identity
```

---

## What you’ll learn

By completing this project, you will get practical experience with:

- Azure resource organization.
- Terraform-based Azure deployments.
- Virtual networking and subnet segmentation.
- Linux VM provisioning in Azure.
- Secure administrative access with SSH keys.
- NSG design and basic traffic control.
- Azure Key Vault and RBAC.
- Managed identity for machine-to-service authentication.
- Compliance-minded infrastructure thinking.
- Building cloud labs that are easy to destroy and rebuild.

This is the project where Azure starts to feel operational instead of theoretical.

---

## Prerequisites

Before you begin, make sure you have:

- An Azure account.
- Azure CLI installed.
- Terraform installed.
- Git installed.
- An SSH key pair for the VM.
- A GitHub repository to store your code and documentation.

Recommended:
- VS Code
- A Markdown preview extension
- A screenshots folder for GitHub and Medium documentation

---

## Project structure

```text
project-1-secure-azure-environment/
├── providers.tf
├── variables.tf
├── network.tf
├── compute.tf
├── security.tf
├── policy.tf
├── outputs.tf
├── terraform.tfvars
├── README.md
└── docs/
    ├── screenshots/
    ├── architecture.md
    └── remediation-notes.md
```

A good reading order is:

1. `providers.tf`
2. `variables.tf`
3. `network.tf`
4. `compute.tf`
5. `security.tf`
6. `policy.tf`
7. `outputs.tf`

That order helps the project make sense from foundation to workload to security and governance.

---

## Step 0 — Set up your machine

Install the required tools and verify they work.

### Azure CLI
```bash
az version
```

### Terraform
```bash
terraform version
```

### Generate a fresh SSH key pair
```bash
ssh-keygen -t ed25519 -f ~/.ssh/azlab -C "azure-lab"
```

This creates:
- `~/.ssh/azlab` → private key
- `~/.ssh/azlab.pub` → public key

Do **not** commit your private key to GitHub.

### Log in to Azure
```bash
az login
az account show --query id -o tsv
curl -4 ifconfig.me
```

Save:
- Your Azure subscription ID
- Your current public IP

You’ll use both in `terraform.tfvars`.

---

## Step 1 — Clone the repo and set your values

Clone your project:

```bash
git clone https://github.com/<your-username>/azure-zero-to-hero.git
cd azure-zero-to-hero/project-1-secure-azure-environment
```

Create `terraform.tfvars`:

```hcl
subscription_id = "PASTE-YOUR-SUBSCRIPTION-ID"
my_ip           = "PASTE-YOUR-PUBLIC-IP"
owner           = "your-name"
```

This file should stay local and should be git-ignored.

---

## Step 2 — Initialize and review the Terraform plan

Run:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
```

What each command does:

- `terraform init` → downloads providers and initializes the project.
- `terraform fmt` → formats the Terraform code.
- `terraform validate` → checks for syntax and reference issues.
- `terraform plan` → shows what Terraform intends to create.

**Important habit:** read the plan before you apply it.  
The plan is your contract. Never apply blindly.

---

## Step 3 — Deploy the environment

Run:

```bash
terraform apply
```

Type `yes` when prompted.

Terraform will create the Azure resources defined in the project. When it finishes, save the output and take screenshots of the deployed environment.

---

## Step 4 — Verify the environment like an operator

Do not stop at “Terraform completed successfully.” Validate what you built.

### 1. Test SSH access

Use the VM public IP from Terraform output:

```bash
ssh -i ~/.ssh/azlab azlabadmin@$(terraform output -raw vm_public_ip)
```

Once connected, confirm password authentication is disabled:

```bash
sudo sshd -T | grep passwordauthentication
```

Expected result:

```text
passwordauthentication no
```

### 2. Test NSG restriction

Try connecting from a different public IP, such as a mobile hotspot.

If SSH fails from that IP, your restriction is working as intended.

### 3. Validate storage settings

In the Azure portal, open the storage account and confirm:
- Secure transfer is enabled
- Minimum TLS is set appropriately
- Public access is disabled

### 4. Validate Key Vault access model

Confirm:
- Key Vault is using RBAC
- Your admin account has the correct access
- The VM identity has read access to secrets
- No credentials are stored locally on the VM for secret retrieval

### 5. Check policy compliance

Open:

**Azure Portal → Policy → Compliance**

Review the assigned compliance initiative and note any findings.

This is one of the most valuable parts of the lab because it turns the project from a simple deployment into a security and governance conversation.

---

## Step 5 — Remediate findings through code

The goal is not perfection on the first run.  
The goal is to:

1. Review a finding.
2. Understand what it means.
3. Fix it in Terraform.
4. Re-apply the code.
5. Re-check the result.

Good examples:
- Tighten storage network access.
- Strengthen Key Vault settings.
- Document a lab risk where an enterprise-grade control is outside the scope of the environment.

This is where the project becomes “zero to hero.”

---

## Step 6 — Destroy the environment

When you are done validating and documenting, destroy the environment:

```bash
terraform destroy
```

This matters for two reasons:
- It saves cost.
- It proves the environment is fully reproducible from code.

A lab you can destroy cleanly is a lab you actually control.

---

## Screenshots to capture

For GitHub and Medium, save screenshots of:

- Terraform apply success
- Resource group overview
- Virtual network and subnets
- NSG inbound rules
- Linux VM overview
- Storage account configuration
- Key Vault RBAC assignments
- Policy compliance dashboard
- Terraform destroy confirmation

These screenshots make the project more believable and much easier to present in an interview.

---

## Interview talking points

Here are the exact kinds of things to say in an interview:

- “I built a segmented Azure environment using Terraform so the infrastructure was repeatable and not dependent on portal clicks.”
- “I used least-privilege NSG rules to restrict SSH access to my IP.”
- “The VM uses SSH keys only, which improves administrative security.”
- “I used managed identity with Key Vault so the VM could retrieve secrets without storing credentials locally.”
- “I included policy and compliance visibility because I wanted the project to reflect governance, not just provisioning.”
- “This project helped me practice Azure in a hands-on way and better understand how the services work together.”

---

## Common issues and fixes

| Problem | Likely cause | Fix |
|---|---|---|
| Terraform cannot authenticate | Azure CLI session expired | Run `az login` again |
| Storage account name is unavailable | Name must be globally unique | Change the name or suffix |
| Key Vault access fails immediately | RBAC propagation delay | Wait 1–2 minutes and retry |
| SSH fails from your main machine | Your public IP changed | Update `my_ip` in `terraform.tfvars` and re-apply |
| Policy view looks empty | Evaluation needs time | Wait and check again |

---

## Why this project matters

This project gave me a practical way to learn Azure by building something real.

Instead of only memorizing service names, I was able to deploy infrastructure, validate access controls, work with networking and identity, and understand how security and governance fit into an Azure environment. That made the learning process much more useful and much easier to remember.

It also gave me a project I could document, explain, improve, and rebuild from scratch.

---

## What I would improve next

If I extend this project, I would add:

- Storage network rules
- Azure Bastion or a stronger admin access pattern
- Monitoring and alerting
- Budget alerts
- Azure Advisor review
- A second application tier
- CI/CD deployment for Terraform
- Additional remediation tracking in code

---

## Final takeaway

This project helped Azure feel real to me.

It was not just about learning names like VNet, NSG, Key Vault, or Policy. It was about building an environment, validating it, understanding the security tradeoffs, and being able to explain the design like an actual cloud administrator.

That was the real win.