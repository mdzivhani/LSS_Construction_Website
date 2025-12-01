#!/bin/bash
###############################################################################
# Leetshego Safety Solutions - Health Monitor with Auto-Recovery
# Continuously monitors application health and automatically recovers failures
###############################################################################

# Configuration
APP_NAME="Leetshego"
APP_DIR="/home/mulalo/applications/lss_construction"
HEALTH_CHECK_URL="http://localhost:8080/health"
CHECK_INTERVAL=60  # Check every 60 seconds
MAX_FAILURES=3     # Auto-recover after 3 consecutive failures
LOG_FILE="/home/mulalo/logs/lss_construction/health-monitor.log"

# Counters
consecutive_failures=0
total_checks=0
total_failures=0
total_recoveries=0

# Logging function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if container is running
check_container() {
    docker ps --filter "name=leetshego-nginx" --format "{{.Status}}" | grep -q "Up"
}

# Check application health
check_health() {
    if curl -sf "$HEALTH_CHECK_URL" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Attempt recovery
attempt_recovery() {
    log_message "RECOVERY: Attempting to recover $APP_NAME..."
    
    cd "$APP_DIR" || return 1
    
    # Try restart first
    log_message "RECOVERY: Restarting services..."
    docker compose restart
    sleep 10
    
    if check_health; then
        log_message "RECOVERY: SUCCESS - Application recovered via restart"
        return 0
    fi
    
    # If restart didn't work, try full redeploy
    log_message "RECOVERY: Restart failed. Attempting full redeploy..."
    docker compose down
    sleep 5
    docker compose up -d
    sleep 15
    
    if check_health; then
        log_message "RECOVERY: SUCCESS - Application recovered via redeploy"
        return 0
    fi
    
    log_message "RECOVERY: FAILED - Manual intervention required"
    return 1
}

# Send alert (can be extended to email/SMS/webhook)
send_alert() {
    local message="$1"
    log_message "ALERT: $message"
    
    # TODO: Add email, Slack, or other notification integrations here
    # Example: echo "$message" | mail -s "Leetshego Alert" admin@example.com
}

# Main monitoring loop
monitor() {
    log_message "========================================="
    log_message "Health Monitor Started for $APP_NAME"
    log_message "Check Interval: ${CHECK_INTERVAL}s"
    log_message "Max Failures Before Recovery: $MAX_FAILURES"
    log_message "========================================="
    
    while true; do
        total_checks=$((total_checks + 1))
        
        # Check if container is running
        if ! check_container; then
            log_message "WARNING: Container not running!"
            consecutive_failures=$((consecutive_failures + 1))
            total_failures=$((total_failures + 1))
            
            if [ $consecutive_failures -ge $MAX_FAILURES ]; then
                send_alert "Container down! Attempting recovery..."
                if attempt_recovery; then
                    consecutive_failures=0
                    total_recoveries=$((total_recoveries + 1))
                fi
            fi
        # Check application health
        elif ! check_health; then
            log_message "WARNING: Health check failed (consecutive: $consecutive_failures)"
            consecutive_failures=$((consecutive_failures + 1))
            total_failures=$((total_failures + 1))
            
            if [ $consecutive_failures -ge $MAX_FAILURES ]; then
                send_alert "Health check failed $MAX_FAILURES times! Attempting recovery..."
                if attempt_recovery; then
                    consecutive_failures=0
                    total_recoveries=$((total_recoveries + 1))
                else
                    send_alert "CRITICAL: Auto-recovery failed! Manual intervention required!"
                fi
            fi
        else
            # Health check passed
            if [ $consecutive_failures -gt 0 ]; then
                log_message "SUCCESS: Health restored (was down for $consecutive_failures checks)"
                consecutive_failures=0
            fi
            
            # Log status every 10 successful checks
            if [ $((total_checks % 10)) -eq 0 ]; then
                log_message "STATUS: Healthy | Total Checks: $total_checks | Failures: $total_failures | Recoveries: $total_recoveries"
            fi
        fi
        
        sleep "$CHECK_INTERVAL"
    done
}

# Handle signals
cleanup() {
    log_message "========================================="
    log_message "Health Monitor Stopped"
    log_message "Final Stats - Checks: $total_checks | Failures: $total_failures | Recoveries: $total_recoveries"
    log_message "========================================="
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start monitoring
monitor
