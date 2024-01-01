#!/bin/bash

    echo -e "\n\e[94m****************************\e[0m"
    echo -e "\e[94mMixnode Active Epoch Checker\e[0m"
    echo -e "\e[94m****************************\e[0m"

# Handle SIGINT (Ctrl+C)
###trap "echo -e '\nCanceled'; exit" SIGINT

# Function to check if a node was active based on the log line
isActive() {
    local logs=$1
    local activeLines=0

    while IFS= read -r line; do
        if [[ $line =~ ([0-9]+)\ in\ last\ 30\ seconds ]] && [ "${BASH_REMATCH[1]}" -ge 100 ]; then
            ((activeLines++))
        fi
    done <<< "$logs"

    if [ "$activeLines" -ge 7 ]; then
        return 0 # Active
    else
        return 1 # Not active
    fi
}

# Function to get the logs for the middle of an epoch
getMidEpochLogs() {
    local date=$1
    local epochStartSeconds=$(date -d "$date" +%s)
    local midEpochSeconds=$((epochStartSeconds + 1800))
    local sinceTime=$(date -d "@$((midEpochSeconds))" +"%Y-%m-%d %H:%M:%S")
    local untilTime=$(date -d "@$((midEpochSeconds + 600))" +"%Y-%m-%d %H:%M:%S")

    # Capture both stdout and stderr
    local logs_output=$(journalctl -u nym-mixnode --since="$sinceTime" --until="$untilTime" -o cat 2>&1)
    local exit_status=$?

    if [ $exit_status -ne 0 ]; then
        # An error occurred while fetching logs
        echo -e "\e[31mError fetching logs: $logs_output\e[0m"
        return 1
    elif [ -z "$logs_output" ]; then
        # No logs were found
        echo -e "\e[94mNo logs found for the specified time range.\e[0m"
        return 1
    else
        echo "$logs_output"
    fi
}

# Function to display a menu and request the number of days
requestDays() {
    while true; do
        echo -e "\n\e[94mEnter the number of days to check or 'q' to exit:\e[0m\n"
        read input
        if [[ "$input" == "q" ]]; then
###            echo -e "\n\e[94mExiting the script.\e[0m"
            echo
            return 1
        elif ! [[ "$input" =~ ^[0-9]+$ ]]; then
            echo -e "\e[31mError: Please enter a valid numerical value.\e[0m"
        else
            days=$input
            break
        fi
    done
}

# Function to display current system time
showCurrentTime() {
    local currentTime=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "\e[94mCurrent system time is: $currentTime\e[0m\n"
}

# Function to ask user if they want to see the start times of active epochs
askToShowActiveEpochs() {
    echo -e "\e[94mShow active Epochs? (y/n):\e[0m\n"
    read answer

    echo

    if [[ "$answer" == "y" ]]; then
        for epoch in "${activeEpochs[@]}"; do
###            echo -e "\e[32mMixnode was active in Epoch started at (year-month-day time):\e[0m \e[92m$epoch\e[0m"
            echo -e "\e[32mMixnode was active in Epoch started at:\e[0m \e[92m$epoch\e[0m"
        done
        showCurrentTime
    fi
}

# Function to check if nym-mixnode service is installed
checkServiceInstalled() {
    if ! systemctl status nym-mixnode &> /dev/null; then
        echo -e "\e[31mService 'nym-mixnode' is not installed or cannot be found.\e[0m"
        return 1
    fi
}

# Main script logic
# Main script logic
main() {
    checkServiceInstalled || return 1
    requestDays || return 1

    echo

    currentDate=$(date +"%Y-%m-%d %H:26:00")
    currentSeconds=$(date -d "$currentDate" +%s)

    # Initialize active epochs count and array
    activeEpochsCount=0
    activeEpochs=()

    local totalEpochs=$((24 * days))
    local processedEpochs=0

    # Loop through each hour in the specified number of days
    for ((i=0; i<24*days; i++)); do
        subtractSeconds=$((i * 3600))
        epochStartSeconds=$((currentSeconds - subtractSeconds))
        epochStartDate=$(date -d "@$epochStartSeconds" +"%Y-%m-%d %H:26:00")

        logs=$(getMidEpochLogs "$epochStartDate")
        if isActive "$logs"; then
            ((activeEpochsCount++))
            activeEpochs+=("$epochStartDate")
        fi

        # Update and display progress
        ((processedEpochs++))
        local progress=$(( (processedEpochs * 100) / totalEpochs ))
        echo -ne "\e[34m\rProcessing: $progress%\e[0m"

    done
    echo -e "\n" # Move to a new line after the loop completes

    # Check if active epochs count is zero and exit if it is
    if [ "$activeEpochsCount" -eq 0 ]; then
        echo -e "\e[94mNo active epochs found. Exiting.\e[0m"
        return 1
    fi

    echo -e "\e[32mMixnode was active in\e[0m \e[92m$activeEpochsCount\e[0m \e[32mEpochs.\e[0m"
    askToShowActiveEpochs
}

# Start the main script logic
main
