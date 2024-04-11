
increase_decrease="$1"
percent="$2"
wob_pipe="/tmp/volume_wob_pipe"
style=volume

if [ "$increase_decrease" = "increase" ] ; then
	wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ ${percent}%+
else
	wpctl set-volume @DEFAULT_AUDIO_SINK@ ${percent}%-
fi

volume=$(echo 'scale=2;' "`wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'`" '*100' | bc | sed 's/\..*//')
echo $volume $style > $wob_pipe


