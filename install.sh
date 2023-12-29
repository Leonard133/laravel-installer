#!/bin/bash
set -e

# Constants
SCRIPT_DIR="$(pwd)"
export SCRIPT_DIR="$SCRIPT_DIR"
PROJECT_DIR="api"
INSTALLER_SERVICE="laravel"
DOCKER_COMPOSE_FILE="$HOME/Development/laravel-installer/docker-compose.yml"
LOG_FILE="setup.log"

# Check if docker compose file exists
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo "Docker compose file not found at $DOCKER_COMPOSE_FILE"
    exit 1
fi

# Function to handle failures
handle_failure() {
    echo "An error occurred. Please check the log file $LOG_FILE for more details."
    docker_teardown
    exit 1
}

# Function for Docker teardown
docker_teardown() {
    echo "Tearing down Docker containers and removing images..."
    IMAGE_ID=$(cd "$(dirname "$DOCKER_COMPOSE_FILE")" && docker-compose images -q $INSTALLER_SERVICE)
    (cd "$(dirname "$DOCKER_COMPOSE_FILE")" && docker-compose down) || { echo "Docker compose down failed"; exit 1; }
    docker rmi -f $IMAGE_ID || { echo "Docker image removal failed"; exit 1; }
}

# Function to run docker-compose exec
run_docker_compose_exec() {
    (cd "$(dirname "$DOCKER_COMPOSE_FILE")" && docker-compose exec $INSTALLER_SERVICE "$@") 2>&1 | tee -a "$LOG_FILE"
}

# Main script execution
if [ ! -d "$PROJECT_DIR" ]; then
    cd "$SCRIPT_DIR"
    
    echo "Building Docker..."

    (cd "$(dirname "$DOCKER_COMPOSE_FILE")" && docker-compose -f "$DOCKER_COMPOSE_FILE" up -d --build) || handle_failure

    echo "Setting up a new Laravel project..."
    run_docker_compose_exec composer create-project laravel/laravel . || handle_failure

    echo "Setting up git..."
    run_docker_compose_exec git init || handle_failure
    run_docker_compose_exec git config --global user.email "docker@docker.com" || handle_failure
    run_docker_compose_exec git config --global user.name "docker" || handle_failure
    run_docker_compose_exec git add . || handle_failure
    run_docker_compose_exec git commit -am "initial" || handle_failure

    echo "Generating Application Key..."
    run_docker_compose_exec php artisan key:generate || handle_failure

    # Laravel packages installation
    echo "Adding Laravel packages to composer.json..."
    PACKAGES=(
        "laravel/telescope"
        "laravel/horizon"
        # "filament/filament:^3.1"
    )
    DEV_PACKAGES=(
        "pestphp/pest"
        "pestphp/pest-plugin-faker"
        "pestphp/pest-plugin-laravel"
        "pestphp/pest-plugin-livewire"
    )

    for package in "${PACKAGES[@]}"; do
        echo "Adding $package to composer.json..."
        run_docker_compose_exec composer require "$package" -W --no-update || handle_failure
    done

    for package in "${DEV_PACKAGES[@]}"; do
        echo "Adding $package to composer.json (dev)..."
        run_docker_compose_exec composer require "$package" -W --dev --no-update || handle_failure
    done

    echo "Updating dependencies and generating autoloader..."
    run_docker_compose_exec composer update || handle_failure

    # Laravel specific post-install commands
    echo "Running post-installation commands for Laravel packages..."
    run_docker_compose_exec php artisan telescope:install || handle_failure
    run_docker_compose_exec php artisan horizon:install || handle_failure
    run_docker_compose_exec ./vendor/bin/pest --init || handle_failure
    # Uncomment the line below if you uncomment filament/filament in PACKAGES
    # run_docker_compose_exec php artisan filament:install --panels || handle_failure

    echo "Commit Updated Package..."
    run_docker_compose_exec git add . || handle_failure
    run_docker_compose_exec git commit -am "added packages" || handle_failure
else
    echo "Directory $PROJECT_DIR already exists. Skipping setup..."
fi
