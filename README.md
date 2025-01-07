# Infrastructure Deployment

This repository is dedicated to deploying infrastructure on AWS using Terraform.

## Installation of Terraform

You can install Terraform on your machine by following these instructions:

- For Debian-based systems, please visit [this link](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).
- For MacOS, you can install Terraform using Homebrew with the following command:

    ```sh
    brew install terraform
    ```

## Configuration with .env File

1. Copy the provided `.env.example` file and create a new file named `.env`.
2. Fill out the necessary variables in the `.env` file.
3. After filling out the variables, run the following command to apply the configuration:

    ```sh
    source .env
    ```

## Initialize Terraform

To initialize Terraform and configure the backend, use the following command.

    ```sh
    terraform init
    ```

## Apply Infrastructure

After successful initialisation the configuration could be applied.

    ```sh
    terraform apply
    ```

**Important Note:** Before applying changes, always verify that only your intended changes will be applied.

## Known issues

