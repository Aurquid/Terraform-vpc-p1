# Terraform-VPC-P1  
# Overview
This project mimics a production-style AWS environment utilizing Terraform.It includes a VPC, public/private subnets, EC2 launch template, Application Load Balancer, Auto Scaling Group, and CloudWatch alarm for CPU-based scaling.The goal is to demonstrate real cloud engineering skills using Infrastructure as Code (IaC), focusing on scalability, monitoring, and cost efficiency.


# 📘 Table of Contents
* [Overview](#overview)
* [Architecture Diagram](#architecture-diagram)
* [Architecture Summary](#architecture-summary)
* [Services Used](#services-used)
* [Deployment](#deployment)
* [IAM Least Privilege](#iam-least-privilege)
* [Tradeoff Analysis](#tradeoff-analysis)
* [Cost Breakdown](#cost-breakdown)
* [Failure Scenario & Recovery Playbook](#failure-scenario-and-recovery-playbook)
* [Lessons Learned](#lessons-learned)
* [Screenshots](#screenshots)


# Architecture Diagram
![Terraform VPC EC2 ALB ASG](TFP1.png)

# Architecture Summary 
* VPC with public + private subnets
* Internet Gateway and NAT Gateway for connectivity
* Route Tables for public and private routing
* Security Groups for inbound/outbound control
* Application Load Balancer to distribute traffic
* Auto Scaling Group that keeps 2 instances (min 2, max 3). It scales out when ASG average CPU > 70% for 2 minutes and scales back in when CPU < 30% for 5 minutes
* IAM Role for SSM access
* EC2 Launch Template defining instance configuration

# Services Used
* VPC
* Subnets( Public and Private)
* Internet Gateway(IGW)
* NAT Gateway
* Route Tables
* Security Groups
* EC2
* Application Load Balancer(ALB)
* Auto Scaling Group(ASG)
* IAM Role(SSM Access)
* CloudWatch(CPU alarm for scaling)
  
                 

 # Deployment
* terraform init
* terraform plan
* terraform apply
* terraform destroy (after testing to avoid charges)

 # IAM Least Privilege
  * EC2 instances use one role with only the AWS-managed `AmazonSSMManagedInstanceCore` policy, so they can be reached through SSM Session Manager     and nothing else
 
  * No SSH keys and no inbound SSH port
 
  * EC2 security group only accepts HTTP from the ALB security group
 
   # Failure Scenario and Recovery Playbook
  ### Scenario : ALB health checks fail
  ### Root Cause: Incorrect security group or user data
  ###  Recovery Steps:
  
   1. Validate SG inbound rules
   2. Check EC2 user data logs
   3. Restart instance or redeploy
   4. Confirm ALB target health
   ### Prevention:
  * Add automated validation
  * Add CloudWatch alarms
 
  
### Scenario: Auto Scaling fails to trigger  
### Root Cause: Misconfigured CloudWatch alarm or missing ASG policy ARN  
### Recovery Steps:  
1. Verify CloudWatch alarm state and threshold  
2. Check alarm actions for correct ASG policy ARN  
3. Re‑apply Terraform configuration  
4. Confirm scaling event in CloudWatch metrics  
### Prevention:
* Validate alarm configuration after deployment

 ##  Tradeoff Analysis
* **EC2 vs Lambda:** EC2 chosen for persistent compute and predictable cost; Lambda offers serverless simplicity but higher per‑request pricing.  
* **ALB vs NLB:** ALB supports HTTP routing and health checks; NLB provides lower latency but lacks path‑based routing.  
* **NAT Gateway vs VPC Endpoints:** NAT Gateway enables outbound internet access for private subnets; endpoints are cheaper for internal AWS traffic only.  
 * **t2.micro vs t2.nano:** t2.micro selected for better baseline performance and demo stability; t2.nano is cheaper but limited for multi‑instance scaling.



# Cost Breakdown 
| Component | Cost | Notes |
| --- | --- | --- |
| EC2 t2.micro | $8.35/mo | charged while running |
| ALB | $16/mo | delete when not testing |
| VPC | $0 | free |
| ASG | $0 | free |
| NAT Gateway| $32-35/mo| charged hourly+ data processed |
|CloudWatch Alarm| $0.10-$0.30| Minimal; charged per metric/alarm |
|Data Transfer| variable| Depends on traffic volume |

# Business Impact
* Cost-efficient scaling
  
* Reduced downtime risk

* Improved reliability

* Lower operational overhead

* Instances in private subnets with no public IPs or SSH

* Monitoring through CloudWatch alarms improves system resilience and scaling.

 # Lessons Learned

   * Value of IAM  least privilege
 
  * How ALB  health checks behave

  * How CloudWatch alarms integrate with Auto Scaling
 
  * How to optimize cloud cost

  * Including health checks for instances for reliability
 
  # Screenshots
  ### VPC and Subnets
  This screenshot shows the AWS VPC Dashboard with all core networking resources created
 <img width="1106" height="539" alt="Screenshot 2026-08-06 020334" src="https://github.com/user-attachments/assets/6730912b-5877-4652-a1de-fe441b82d8aa" />
  This screenshot shows the public and private subnets for A and B
  <img width="1113" height="280" alt="Screenshot 2026-08-06 020552" src="https://github.com/user-attachments/assets/542b4545-1663-40b9-8cc9-c5a1cef4f1e2" />
  
  ### Route Table for IGW
   Public route table for the internet gateway
  <img width="932" height="210" alt="Screenshot 2026-08-06 020619" src="https://github.com/user-attachments/assets/3b6919e4-ab11-4a41-aea7-12d3e14a7905" />
  ### Route Table for NAT Gateway
  Private route table for the NAT gateway
  <img width="919" height="224" alt="Screenshot 2026-08-06 020633" src="https://github.com/user-attachments/assets/41eb2cf4-f7ac-425c-bac8-8dee51f47ee4" />
  ### Internet Gateway
  Internet gateway connected to the VPC.
  <img width="784" height="24" alt="Screenshot 2026-08-06 020727" src="https://github.com/user-attachments/assets/6fad54a7-0feb-42bd-8ddc-6a632a6beeb7" />
  Internet gateway details. 
 <img width="1120" height="664" alt="Screenshot 2026-08-06 021138" src="https://github.com/user-attachments/assets/e089d849-77b7-4b30-a47d-8c87b0e3cac6" />
 ### NAT Gateway
  NAT Gateway details.
 <img width="947" height="529" alt="Screenshot 2026-08-06 021418" src="https://github.com/user-attachments/assets/92b7c1fa-16f7-4a73-ac21-1f73150be64a" />
 ### Security Groups
The security group details for the Application Load Balancer (ALB)
 <img width="921" height="535" alt="Screenshot 2026-08-06 022849" src="https://github.com/user-attachments/assets/6710b01a-1cf8-4e75-90cc-c7ba4d2e0e72" />
 
 The inbound rules for the Application Load Balancer (ALB)
 <img width="915" height="461" alt="Screenshot 2026-08-06 022911" src="https://github.com/user-attachments/assets/15a20f58-3800-49f9-b36b-696b5f268557" />
 
 The outbound rules for the Application Load Balancer (ALB)
 <img width="918" height="461" alt="Screenshot 2026-08-06 022929" src="https://github.com/user-attachments/assets/ac518532-5066-460b-86a9-5cb8a3117219" />
 
 Security group details for the instance 
 <img width="910" height="469" alt="Screenshot 2026-08-06 023514" src="https://github.com/user-attachments/assets/72248230-340b-4ba4-b4e8-1cbfb7fbd617" />
 
 Instance inbound rules
 <img width="929" height="467" alt="Screenshot 2026-08-06 023545" src="https://github.com/user-attachments/assets/a69d9bc3-212b-49fd-bba7-e71a15164e9a" />
 
Instance outbound rules

<img width="944" height="488" alt="Screenshot 2026-08-06 023620" src="https://github.com/user-attachments/assets/009cd1e1-b0d6-4b44-a624-90203c5eb0f6" />

### Launch Template
Launch template details

<img width="928" height="530" alt="Screenshot 2026-08-06 025409" src="https://github.com/user-attachments/assets/d6516af5-8ac6-483c-a6d7-924c4b43bcbc" />

### IAM EC2 SSM Role
SSM role details

<img width="862" height="310" alt="Screenshot 2026-08-06 025734" src="https://github.com/user-attachments/assets/26267c91-e98d-419f-80d5-ae2af21077de" />

SSM role permissions

<img width="908" height="488" alt="Screenshot 2026-08-06 025850" src="https://github.com/user-attachments/assets/4c518e59-ec4f-4cd3-b7de-5a627420817d" />

SSM JSON block

<img width="876" height="505" alt="Screenshot 2026-08-06 025915" src="https://github.com/user-attachments/assets/5de02f0f-e77b-4604-aad9-e0fb0afb42cd" />

### Auto Scaling Group

Auto Scaling Group(ASG) capacity configuration 

<img width="910" height="498" alt="Screenshot 2026-08-06 030244" src="https://github.com/user-attachments/assets/a64dcd54-21dc-43a3-b78a-78354ecea237" />

Auto Scaling Group(ASG) overview

<img width="472" height="285" alt="Screenshot 2026-08-06 030414" src="https://github.com/user-attachments/assets/01f9d7cc-f340-487f-b0ef-ab553d54f77c" />

Auto Scaling Group(ASG) CPU metric 

<img width="914" height="279" alt="Screenshot 2026-08-06 030552" src="https://github.com/user-attachments/assets/d4e0940e-a7b6-4e8f-a947-7b7afce30b4d" />

### Instance
Instance summary

<img width="947" height="535" alt="Screenshot 2026-08-06 031418" src="https://github.com/user-attachments/assets/f6a4bcae-e1c3-4d64-81ae-621c78a3ac7f" />

Second instance summary

<img width="915" height="519" alt="Screenshot 2026-08-06 031446" src="https://github.com/user-attachments/assets/9dd4eb72-40a4-4532-aebb-c3fd8a73eae1" />

### Application Load Balancer
Application Load Balancer details
<img width="907" height="513" alt="Screenshot 2026-08-06 032303" src="https://github.com/user-attachments/assets/adb1c784-66a9-49a5-9396-d762741e2aa0" />

Listener and rules

<img width="890" height="529" alt="Screenshot 2026-08-06 032343" src="https://github.com/user-attachments/assets/a078f813-ba09-493a-af63-66007c278101" />

Target groups details with health checks 

<img width="907" height="532" alt="Screenshot 2026-08-06 032610" src="https://github.com/user-attachments/assets/3b61a6ff-9e3a-41ba-85ce-ee71337e6649" />

Validation ALB DNS test

<img width="485" height="179" alt="Screenshot 2026-08-06 032900" src="https://github.com/user-attachments/assets/406e2f15-82ed-4e39-9398-65a28bc869fc" />

CloudShell validation test 

<img width="352" height="175" alt="Screenshot 2026-08-06 033141" src="https://github.com/user-attachments/assets/1a6fda58-d36f-46f9-9111-fe773615d1a7" />

### Failure and Recovery
Stopping instance
<img width="908" height="200" alt="Screenshot 2026-08-06 033714" src="https://github.com/user-attachments/assets/00c1e28a-7f7f-43b0-83bb-cd46b0004866" />

Target group marks instance as unhealthy

<img width="926" height="518" alt="Screenshot 2026-08-06 033907" src="https://github.com/user-attachments/assets/1b7ff661-92d4-4dfe-b9ce-1ab6a32c9b43" />

ASG replaces unhealthy instance with a healthy one 

<img width="927" height="529" alt="Screenshot 2026-08-06 034211" src="https://github.com/user-attachments/assets/f5218f13-62f7-4995-b8a5-919c22adef8b" />
























 

 

 
 

 
 


 

  

 
 
 
 

