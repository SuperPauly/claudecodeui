# DOCKER_SETUP.md

## Introduction
Docker is a powerful platform that allows you to automate the deployment of applications inside lightweight containers. This document provides comprehensive instructions for deploying the `SuperPauly/claudecodeui` application using Docker and Cline CLI.

## Prerequisites
- **Docker**: Ensure Docker is installed on your machine. Follow the [official Docker installation guide](https://docs.docker.com/get-docker/) for your operating system.
- **Cline CLI**: Make sure you have Cline CLI installed. You can find the installation instructions on the [Cline CLI documentation page](https://cline-cli.example.com/docs).

## Setting Up the Environment
1. Clone the repository:
   ```bash
   git clone https://github.com/SuperPauly/claudecodeui.git
   cd claudecodeui
   ```

## Docker Configuration
- **Dockerfile**: The Dockerfile is located in the root of the project. It contains the necessary instructions to build the application image.
- **docker-compose.yml**: If you're using Docker Compose, ensure the `docker-compose.yml` file is configured correctly for your environment.

## Building the Docker Image
To build the Docker image, run the following command:
```bash
docker build -t claudecodeui .
```
This command will create a Docker image named `claudecodeui` using the instructions in the Dockerfile.

## Running the Docker Container
To run the Docker container, use the command:
```bash
docker run -d -p 8080:80 --name claudecodeui claudecodeui
```
This command maps port 8080 on your host to port 80 on the container. Adjust the ports as necessary for your setup.

## Accessing the Application
Once the container is running, you can access the application in your web browser by navigating to:
```
http://localhost:8080
```

## Using Cline CLI with Docker
To use Cline CLI commands within the Docker container, you can execute:
```bash
docker exec -it claudecodeui cline <command>
```
Replace `<command>` with the actual Cline command you want to run. For example:
```bash
docker exec -it claudecodeui cline deploy
```

## Troubleshooting
- **Container not starting**: Check the logs using `docker logs claudecodeui` to identify issues.
- **Port conflicts**: Ensure that the ports you are trying to bind are not already in use by another application.

## Conclusion
This document provides a comprehensive guide for deploying the `SuperPauly/claudecodeui` application using Docker and Cline CLI. For further information, consult the official Docker and Cline CLI documentation.