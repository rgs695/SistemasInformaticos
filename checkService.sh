#!/bin/bash

# Check if a parameter has been passed
if [ -z "$1" ]; then
    echo "Please provide a service name as a parameter."
    exit 1
fi

SERVICE=$1

# Check if the service is running
if systemctl --quiet is-active $SERVICE; then
    echo "The $SERVICE is running."
else
    echo "The $SERVICE is not running. Attempting to restart it now."

    # Try to restart the service
    systemctl restart $SERVICE

    # Capture the status of the restart operation
    RESTART_STATUS=$?

    # Print the result of the restart operation
    if [ $RESTART_STATUS -eq 0 ]; then
        echo "The $SERVICE was successfully restarted."
    else
        echo "The $SERVICE failed to restart."
    fi

    # Show the final state of the service
    if systemctl --quiet is-active $SERVICE; then
        echo "The $SERVICE is now running."
    else
        echo "The $SERVICE is still not running."
    fi
fi