


increase_decrease="$1"
percent="$2"
wob_pipe="/tmp/volume_wob_pipe"
style=brightness

if [ "$increase_decrease" = "increase" ] ; then
	brightnessctl set ${percent}%+
else
	brightnessctl set ${percent}%-
fi

brightness=$(echo 'scale=2;' "(`brightnessctl get`" '/ 255.0) * 100' | bc | sed 's/\..*//')
echo $brightness $style > $wob_pipe


