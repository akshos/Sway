
SLEEP_DURATION=4
PING_SLEEP=8

ping_sleep_time=0
internet_status="󰂭"

battery_name=$(upower --enumerate | grep 'BAT')

print_status_line() {

    # Retrieve date and time
    current_date=$(date +'%b %d') # Date fomat in <Mon> <dayOfMonth>. eg: Apr 06
    current_time=$(date +'%R') # Time format in <hour>:<minute>, hour and minute are 0 padded. eg: 09:05

    # Retrieve battery capacity
    #battery_charge=$(cat /sys/class/power_supply/BAT1/capacity)
    battery_charge=$(upower --show-info $battery_name | grep -E "percentage" | awk '{print $2}' | sed 's/%//')

    # Retrieve battery status
    battery_status=$(upower --show-info $battery_name | grep -E "state" | awk '{print $2}')

    # Retrieve power usage
    power_usage=$(upower --show-info $battery_name | grep -E "energy-rate" | awk '{print $2}' | sed 's/W//' | xargs printf '%.*f' 1)

    battery_foreground=""

    if [ "$battery_status" = "charging" ] ; then
        battery_icon="󰂄"
        if [ $battery_charge -eq 100 ] ; then
            battery_foreground="foreground='#00eb46'"
        else
            battery_foreground="foreground='#facd1b'"
        fi
    elif [ $battery_charge -gt 95 ] ; then
        battery_icon="󰁹"
    elif [ $battery_charge -gt 89 ] ; then
        battery_icon="󰂂"
    elif [ $battery_charge -gt 79 ] ; then
        battery_icon="󰂁"
    elif [ $battery_charge -gt 69 ] ; then
        battery_icon="󰂀"
    elif [ $battery_charge -gt 59 ] ; then
        battery_icon="󰁿"
    elif [ $battery_charge -gt 49 ] ; then
        battery_icon="󰁾"
    elif [ $battery_charge -gt 39 ] ; then
        battery_icon="󰁽"
    elif [ $battery_charge -gt 29 ] ; then
        battery_icon="󰁼"
    elif [ $battery_charge -gt 19 ] ; then
        battery_icon="󰁻"
        battery_foreground="foreground='#ed620c'"
    elif [ $battery_charge -gt 9 ] ; then
        battery_icon="󰁺"
        battery_foreground="size='large' weight='bold' foreground='#d41313'"
    else
        battery_icon="󰂎"
        battery_foreground="size='x-large' weight='bold' foreground='#d41313'"
    fi

    ethernet_name=enp2s0
    wifi_name=wlan0

    ethernet_link=$(ip link | grep $ethernet_name | awk '{print $9}')
    wifi_link=$(ip link | grep $wifi_name | awk '{print $9}')

    if [ "$ethernet_link" = "UP" ] ; then
        ethernet_status="󰈀"
	ethernet_link_speed=`cat /sys/class/net/enp2s0/speed`
    else 
        ethernet_status="󰈂"
	ethernet_link_speed=""
    fi

    ethernet_status="<span size='large'>$ethernet_status</span>"

    if [ "$ethernet_link_speed" = "1000" ]; then
	ethernet_status="$ethernet_status 1G"
    elif [ "$ethernet_link_speed" = "100" ]; then
	ethernet_status="$ethernet_status 100M"
    fi

    if [ "$wifi_link" = "UP" ] ; then
        wifi_status="󰖩"
	wifi_name=" $(iwctl station wlan0 show | grep "Connected network" | awk '{print $3}')"
    else
        wifi_status="󰖪"
    fi

    wifi_status="<span size='large'>$wifi_status</span>${wifi_name}"

    if [ $ping_sleep_time -ge $PING_SLEEP ] ; then
        ping_time=$(ping -c 1 google.com | grep -oP 'time=\d++' | awk -F= '{print $2}')

        if [ -z "$ping_time" ] ; then
            internet_status="󰂭"
        else
            internet_status="<span size='large'></span> ${ping_time}ms"
        fi

        ping_sleep_time=0
    else
        ping_sleep_time=$(( $ping_sleep_time + $SLEEP_DURATION ))
    fi

    screen_brightness=$(brightnessctl get)
    brightness_percent=$(echo 'scale=2;' "(`brightnessctl get`" '/ 255.0) * 100' | bc | sed 's/\..*//')
    
    if [ $screen_brightness -ge 254 ] ; then
        brightness_status="󰛨"
    elif [ $screen_brightness -ge 230 ] ; then
        brightness_status="󱩖"
    elif [ $screen_brightness -ge 200 ] ; then
        brightness_status="󱩕"
    elif [ $screen_brightness -ge 170 ] ; then
        brightness_status="󱩔"
    elif [ $screen_brightness -ge 150 ] ; then
        brightness_status="󱩓"
    elif [ $screen_brightness -ge 120 ] ; then
        brightness_status="󱩒"
    elif [ $screen_brightness -ge 100 ] ; then
        brightness_status="󱩑"
    elif [ $screen_brightness -ge 70 ] ; then
        brightness_status="󱩐"
    elif [ $screen_brightness -ge 50 ] ; then
        brightness_status="󱩏"
    else
        brightness_status="󱩎"
    fi

    brightness_status="<span size='large'>$brightness_status</span> ${brightness_percent}%"

    default_sink_volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
    default_sink_mute=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $3}')
    default_source_mute=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print $3}')
    default_sink_volume=$(echo "scale=0; ${default_sink_volume}*100" | bc | sed 's/\.00//') 

    if [ "$default_sink_mute" = "[MUTED]" ] ; then
        volume_status=""
    elif [ $default_sink_volume -ge 60 ] ; then
        volume_status="" 
    elif [ $default_sink_volume -ge 30 ] ; then
        volume_status="" 
    else
        volume_status="" 
    fi

    volume_status="<span size='large'>$volume_status</span> ${default_sink_volume}%"

    if [ "$default_source_mute" = "[MUTED]" ] ; then
        mic_status="󰍭"
    else 
        mic_status="󰍬"
    fi

    mic_status="<span size='large'>$mic_status</span>"

    load_status="<span size='large'> </span> $(cat /proc/loadavg | awk '{print $1}')"

    memory_status="<span size='large'></span> $(free -h | grep Mem | awk '{print $7}')"
        
    echo "${memory_status} | ${load_status} | ${mic_status} | ${volume_status} | ${wifi_status} - ${ethernet_status} - ${internet_status} | ${brightness_status} |  ${current_date} -  ${current_time} | 󱐋 ${power_usage}W <span $battery_foreground>${battery_icon} ${battery_charge}%</span> "

}

while print_status_line ; do
    sleep $SLEEP_DURATION
done
