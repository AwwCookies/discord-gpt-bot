#!/bin/bash

# Stop any existing containers named "discord-gpt-bot"
echo "Stopping any existing containers named 'discord-gpt-bot'..."
docker stop discord-gpt-bot

# Remove any existing containers named "discord-gpt-bot"
echo "Removing any existing containers named 'discord-gpt-bot'..."
docker rm -f discord-gpt-bot

# Remove any existing images named "discord-gpt-bot:latest"
echo "Removing any existing images named 'discord-gpt-bot:latest'..."
docker rmi --force discord-gpt-bot:latest

# Build a new Docker image named "discord-gpt-bot" from the Dockerfile in the current directory
echo "Building new Docker image from the Dockerfile in the current directory..."
docker build -t discord-gpt-bot:latest .

# Run a new container named "discord-gpt-bot" using the newly built image and the environment variables in .env file
echo "Starting a new container named 'discord-gpt-bot' using the newly built image and the environment variables in '.env' file..."
docker run --name discord-gpt-bot --env-file .env -d discord-gpt-bot:latest

# Remove any orphaned Docker images
echo "Removing any orphaned Docker images..."
docker image prune -f

# Print a message to indicate that the script has completed
echo "The 'build_and_run.sh' script has completed successfully."

# Show the logs of the newly created container
docker logs discord-gpt-bot -tf