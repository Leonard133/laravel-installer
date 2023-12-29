# Laravel Dockerized Application

This repository contains the necessary configuration to set up and run a Laravel application using Docker.

## Overview

- `Dockerfile`: Sets up the PHP environment with necessary extensions for a Laravel application.
- `docker-compose.yml`: Defines the Docker services, including the Laravel application service.
- `install.sh`: A shell script for setting up the Laravel project within the Docker container.

## Prerequisites

- Docker and Docker Compose installed on your machine.
- Basic knowledge of Docker and Laravel.

## Installation

1. **Clone the Repository:**
   ```
   git clone https://github.com/Leonard133/laravel-installer.git
   ```

2. **Run the Installation Script:**
   Navigate to the cloned directory and execute:
   ```
   bash install.sh
   ```
   This script will:
   - Check for the Docker Compose file.
   - Build and spin up Docker containers.
   - Set up a new Laravel project.
   - Initialize a Git repository in the project.
   - Add necessary packages to the project.

## Configuration

- **Docker Compose:**
  - The `docker-compose.yml` file defines the Laravel service and mounts the project directory to the container.
- **Dockerfile:**
  - Builds an image based on `php:8.3-fpm`.
  - Installs PHP extensions required for Laravel.
  - Sets up Composer for dependency management.

## Usage

- After installation, your Laravel application will be running inside the Docker container.
- You can interact with your application as you would normally do with any Laravel project.

## Troubleshooting

- If you encounter any issues during the setup, please check the `setup.log` file for error details.
- Ensure Docker is running correctly on your machine.

## Contributions

- Contributions to this project are welcome. Please fork the repository and submit a pull request with your changes.
