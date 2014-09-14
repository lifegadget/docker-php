#!/bin/bash

echo "Running Pool Setup"
if [[ -z "$FPM_POOL_DIRECTORY"]]; then
	echo "FPM_POOL_DIRECTORY not set so proceeding with a container-managed setup of pools"
	env
elif [[ -z "$FPM_SOCKET_DIRECTORY"]] && [[ -z "$"  ]]
	