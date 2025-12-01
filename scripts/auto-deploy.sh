#!/bin/bash
# Automated deployment script for Leetshego Construction Website
# Pulls latest changes from main branch and redeploys the application

set -e  # Exit on error

# Configuration
REPO_DIR="/home/mulalo/applications/lss_construction"
LOG_DIR="/home/mulalo/logs/lss_construction/deployments"
LOG_FILE="${LOG_DIR}/auto-deploy-$(date +%Y%m%d-%H%M%S).log"
BRANCH="main"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to send notification (optional - can be extended)
notify() {
    log "NOTIFICATION: $1"
    # Add email/slack notification here if needed
}

log "=========================================="
log "Starting automated deployment for Leetshego Construction"
log "=========================================="

# Change to repository directory
cd "$REPO_DIR" || {
    log "ERROR: Failed to change to repository directory"
    exit 1
}

# Check if there are uncommitted changes
if [[ -n $(git status -s) ]]; then
    log "WARNING: Uncommitted changes detected. Stashing changes..."
    git stash save "Auto-stash before deployment $(date +%Y%m%d-%H%M%S)" >> "$LOG_FILE" 2>&1
fi

# Fetch latest changes
log "Fetching latest changes from origin..."
if ! git fetch origin >> "$LOG_FILE" 2>&1; then
    log "ERROR: Failed to fetch from origin"
    notify "Leetshego deployment failed: Could not fetch from origin"
    exit 1
fi

# Get current commit hash
CURRENT_COMMIT=$(git rev-parse HEAD)
log "Current commit: $CURRENT_COMMIT"

# Get latest commit hash from remote main
LATEST_COMMIT=$(git rev-parse origin/$BRANCH)
log "Latest commit on origin/$BRANCH: $LATEST_COMMIT"

# Check if update is needed
if [ "$CURRENT_COMMIT" = "$LATEST_COMMIT" ]; then
    log "Already up to date. No deployment needed."
    log "=========================================="
    exit 0
fi

log "New changes detected. Proceeding with deployment..."

# Checkout main branch
log "Checking out $BRANCH branch..."
if ! git checkout "$BRANCH" >> "$LOG_FILE" 2>&1; then
    log "ERROR: Failed to checkout $BRANCH branch"
    notify "Leetshego deployment failed: Could not checkout $BRANCH"
    exit 1
fi

# Pull latest changes
log "Pulling latest changes..."
if ! git pull origin "$BRANCH" >> "$LOG_FILE" 2>&1; then
    log "ERROR: Failed to pull latest changes"
    notify "Leetshego deployment failed: Could not pull changes"
    exit 1
fi

# Build and deploy with docker-compose
log "Building Docker image..."
if docker compose build >> "$LOG_FILE" 2>&1; then
    log "Build completed successfully"
else
    log "ERROR: Build failed"
    notify "Leetshego deployment failed: Build error"
    exit 1
fi

log "Stopping existing container..."
docker compose down >> "$LOG_FILE" 2>&1 || true

log "Starting services..."
if docker compose up -d >> "$LOG_FILE" 2>&1; then
    log "Services started successfully"
else
    log "ERROR: Failed to start services"
    notify "Leetshego deployment failed: Could not start services"
    exit 1
fi

# Wait for services to be healthy
log "Waiting for services to become healthy..."
sleep 20

# Check service health
CONTAINER_STATUS=$(docker ps --filter "name=leetshego-nginx" --format "{{.Status}}" || true)
log "Container status: $CONTAINER_STATUS"

# Clean up old Docker images
log "Cleaning up old Docker images..."
docker image prune -f >> "$LOG_FILE" 2>&1 || true

# Clean up old logs (keep last 60 days)
log "Cleaning up old deployment logs..."
find "$LOG_DIR" -name "*.log" -mtime +60 -delete 2>> "$LOG_FILE" || true

NEW_COMMIT=$(git rev-parse HEAD)
log "Deployment completed successfully"
log "Deployed commit: $NEW_COMMIT"
log "=========================================="

notify "Leetshego deployed successfully to commit $NEW_COMMIT"

exit 0
