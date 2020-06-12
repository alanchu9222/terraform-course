# pbi-aws
Microsoft Power BI frontend with Amazon Redshift backend.

# Steps to test the terraform generated infrastructure

1. Run an Terraform to provision the initial development environment
2. SSH into an Amazon EC2 Linux instance to generate a sample dataset.
3. Configure the data warehouse by creating and loading data into Amazon Redshift tables.
4. Install and configure the Power BI Desktop.
5. Configure a data gateway in Power BI.
6. Install the Power BI mobile app so you can consume the visuals from your phone.

## SSH into an Amazon EC2 Linux instance to generate a sample dataset.
1. ssh -i test-key.pem ec2-user@ec2-user@3.250.12.228