#!/bin/bash
export TOP_PID=$$

# Check if whiptail is available
if ! command -v whiptail &> /dev/null; then
    echo "whiptail command not found. Please install it and try again."
    return 1
fi

if [[ $EUID -eq 0 ]]; then
   echo "it is adviced not to run this script as sudo"
   exit 1
fi

# Display available theme list and return selected option
select_theme() {
    local title="$1"

    # Get the list from plasma-apply-colorscheme -l
    local COLORSCHEME_LIST=$(plasma-apply-colorscheme -l | grep "\*")
    local MENU_OPTIONS=()
    while IFS= read -r line; do
        MENU_OPTIONS+=("$line" "")
    done <<< "$COLORSCHEME_LIST"

    local SELECTED_COLORSCHEME=$(whiptail --nocancel --title "$title" --menu "Choose your option:" 25 78 16 "${MENU_OPTIONS[@]}" 3>&1 1>&2 2>&3)

    if [[ -z "$SELECTED_COLORSCHEME" ]]; then
        kill -s TERM $TOP_PID
    else
        echo "$SELECTED_COLORSCHEME"
    fi
}

# Check if the input is an integer and within the range [0, 23] and also not equal to first argument
get_hour() {
    local prompt="$1"
    local excluded="$2"
    local msg=""
    local input_value

    while true; do
        read -p "$prompt " input_value
        # Check if the input is an integer and within the range
        if [[ "$input_value" =~ ^[0-9]+$ ]] && ((input_value >= 0 && input_value <= 23 && input_value != excluded )); then
            echo "$input_value"
            return 0
        fi
    done
}

clean_string() {
    local input_string="$1"
    local cleaned_string=$(echo "$input_string" | sed 's/\*//g; s/(current color scheme)//g; s/^[ \t]*//;s/[ \t]*$//')
    echo "$cleaned_string"
}

# Build the content of the theme-switcher script file
# User preferences on theme switching
echo -e "\e[36m\e[1m
Answer the following questions based on your geographical location and preferences\e[0m
"
DAYTIME_BEGIN=$(get_hour "begin of daytime theme: " -1)
DAYTIME_END=$(get_hour "end of daytime theme: " DAYTIME_BEGIN)

COND_TOKEN="&&"
if [[ "$DAYTIME_BEGIN" -gt "$DAYTIME_END" ]]; then
    COND_TOKEN="||"
fi

DAY_THEME=$(select_theme "Select a KDE plasma colorscheme for daytime")
NIGHT_THEME=$(select_theme "Select a KDE plasma colorscheme for nighttime")
DAY_THEME=$(clean_string "$DAY_THEME")
NIGHT_THEME=$(clean_string "$NIGHT_THEME")

echo -e "\e[1m\e[31;4m
Final configuration is:\e[0m"

echo -e "\e[1m\e[32m
The \e[33m$DAY_THEME\e[32m theme starts at \e[32m\e[4m$DAYTIME_BEGIN\e[0m\e[1m\e[32m. At \e[32m\e[4m$DAYTIME_END\e[0m\e[1m\e[32m, the theme will switch to \e[33m$NIGHT_THEME
\e[0m"


SWITCHER_CONTENT="#!/bin/bash
HOUR=\$(date +"%H")

if [ \$HOUR -ge $DAYTIME_BEGIN ] $COND_TOKEN [ \$HOUR -lt $DAYTIME_END ]; then
    plasma-apply-colorscheme $DAY_THEME
else
    plasma-apply-colorscheme $NIGHT_THEME
fi
"

# Write to file
SWITHCER_PATH="./theme-switcher.sh"
echo "${SWITCHER_CONTENT}" > "${SWITHCER_PATH}"
echo "File ${SWITHCER_PATH} generated successfully!"



# Build the content of the systemd service unit file
# Current user's info
CURRENT_USER=$(whoami)
USER_ID=$(id -u)

SERVICE_CONTENT="[Unit]
Description=Timer to switch KDE Plasma color scheme

[Service]
User=${CURRENT_USER}
Group=${CURRENT_USER}
Type=oneshot
Environment=\"DISPLAY=:0\"
Environment=\"XAUTHORITY=/run/user/${USER_ID}/xauth_KDANKZ\"
Environment=\"XDG_RUNTIME_DIR=/run/user/${USER_ID}\"
ExecStart=/usr/local/bin/theme-switcher.sh"

# Write to file
SERVICE_PATH="./theme-switching.service"
echo "${SERVICE_CONTENT}" > "${SERVICE_PATH}"
echo "File ${SERVICE_PATH} generated successfully!"



# Build the content of the timer unit file
TIMER_CONTENT="[Unit]
Description=Timer to switch KDE Plasma color scheme

[Timer]
OnBootSec=3min
OnUnitActiveSec=3min

[Install]
WantedBy=timers.target
"

TIMER_PATH="./theme-switching.timer"
echo "${TIMER_CONTENT}" > "${TIMER_PATH}"
echo "File ${TIMER_PATH} generated successfully!"



echo -e "\e[32m
To finish installation run: \e[33msudo ./deploy.sh\e[0m
\e[32mTo uninstall run: \e[33msudo ./remove.sh\e[0m
\e[32mTo reinstall run: \e[33m./configure.sh \e[32m and then \e[33msudo ./deploy.sh\e[0m
"
