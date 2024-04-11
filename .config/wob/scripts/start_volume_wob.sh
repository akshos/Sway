#!/bin/bash

## Copy this file to /usr/local/bin

WOB_PIPE_FILE="/tmp/volume_wob_pipe"

while true ; do

	if [ -f ${WOB_PIPE_FILE} ] ; then
		rm ${WOB_PIPE_FILE}
	fi
	
	mkfifo ${WOB_PIPE_FILE}

	tail -f ${WOB_PIPE_FILE} | wob --config $HOME/.config/wob/volume_wob.ini

	sleep 5
	
done


