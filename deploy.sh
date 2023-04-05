#!/bin/bash

set -euo pipefail # Enable strict mode

CONTAINER_NAME="discord-gpt-bot" # Name of the Docker container
TAG="latest" # Tag of the Docker image

# Stop any existing containers named $CONTAINER_NAME
echo "🛑 Stopping any existing containers named '"$CONTAINER_NAME"'..."
if docker stop "$CONTAINER_NAME" > /dev/null 2>&1; then
  echo "✅ Container stopped successfully."
else
  echo "❌ No container named '"$CONTAINER_NAME"' was found."
fi

# Remove any existing containers named $CONTAINER_NAME
echo "🗑️ Removing any existing containers named '"$CONTAINER_NAME"'..."
if docker rm -f "$CONTAINER_NAME" > /dev/null 2>&1; then
  echo "✅ Container removed successfully."
else
  echo "❌ No container named '"$CONTAINER_NAME"' was found."
fi

# Remove any existing images named $CONTAINER_NAME$TAG
echo "🗑️ Removing any existing images named '"$CONTAINER_NAME":"$TAG"'..."
if docker rmi --force "$CONTAINER_NAME":"$TAG" > /dev/null 2>&1; then
  echo "✅ Image removed successfully."
else
  echo "❌ No image named '"$CONTAINER_NAME":"$TAG"' was found."
fi

# Build a new Docker image named $CONTAINER_NAME from the Dockerfile in the current directory
echo "🔨 Building new Docker image from the Dockerfile in the current directory..."
if docker build -t "$CONTAINER_NAME":"$TAG" . > /dev/null 2>&1; then
  echo "✅ Image built successfully."
else
  echo "❌ Image build failed."
  exit 1
fi

# Run a new container named $CONTAINER_NAME using the newly built image and the environment variables in .env file
echo "🚀 Starting a new container named '"$CONTAINER_NAME"' using the newly built image and the environment variables in '.env' file..."
if docker run --name "$CONTAINER_NAME" --env-file .env -d "$CONTAINER_NAME":"$TAG" > /dev/null 2>&1; then
  echo "✅ Container started successfully."
else
  echo "❌ Container start failed."
  exit 1
fi

# Print a message to indicate that the script has completed
echo "✅ The 'deploy.sh' script has completed successfully."

# Show the logs of the newly created container
echo "📜 Showing logs for container '"$CONTAINER_NAME""
docker logs "$CONTAINER_NAME" -tf &
# Store the PID of the last background process
PID=$!

# Wait for input, and exit the script if 'q' is pressed
while true; do
  echo "🐿️ Press 'q' to exit. 🐿️"
  read -r -n 1 -s input
  if [[ $input == "q" ]]; then
    echo "🚪 Exiting..."
    # Kill the background process
    kill $PID
    exit 0
  fi
done
