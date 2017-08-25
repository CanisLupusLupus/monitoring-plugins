#!/bin/bash
#
# check_systemctl_service_active checks if systemctl service is active
#
# Copyright (c) 2017 CanisLupusLupus
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

function show_help() {
	cat << EOF
Usage: ${0##*/} [-h] [-s SERVICE]
Check if SERVICE is active

	-h	display this help and exit
	-s	service to check
EOF
}
SERVICE=
while getopts ":hs:" opt; do
	case "$opt" in
		h)	show_help
			exit 0;
			;;
		s)	SERVICE=$OPTARG
			;;
		*)	show_help
			exit 1;
			;;
	esac
done
if [ -z $SERVICE ]; then
	echo "Service is missing"
	exit 1;
fi
SYSTEMCTL=$(which systemctl)
if [ $? -ne 0 ]; then
	echo "systemctl is missing"
	exit 1;
fi
STATUS=`"${SYSTEMCTL}" is-active "$SERVICE"`
SYSTEMCTL_STATUS=$?
RETURN_CODE=3
RETURN_TEXT=
if [ $SYSTEMCTL_STATUS -eq 0 ]; then
	RETURN_TEXT="Service status: $STATUS"
	RETURN_CODE=0
else
	exec 3>&1
	S2_TEXT=$("${SYSTEMCTL}" is-enabled "$SERVICE" 2>&1 1>&3)
	S2_STATUS=$?
	exec 3>&-
	if [ $S2_STATUS -eq 0 ]; then
		RETURN_TEXT="Service status: $STATUS"
	else
		RETURN_TEXT="Service is not active, current service status: $S2_TEXT"
	fi
	RETURN_CODE=2
fi
echo "$RETURN_TEXT|"
exit $RETURN_CODE
