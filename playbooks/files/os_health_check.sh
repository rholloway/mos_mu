#!/bin/bash

RET=0
OUTPUT=""

check_nova ()
{
	OUT=$(nova service-list)
	if (( $? != 0 )); then
		let 'RET|=1'
	fi
	OUT=$(echo -e "${OUT}" | grep -i down)
	if (( $? == 0 )); then
		let 'RET|=2'
		OUTPUT+="### nova:\n${OUT}\n"
	fi
}

check_neutron ()
{
	OUT=$(neutron agent-list)
	if (( $? != 0 )); then
		let 'RET|=4'
	fi
	OUT=$(echo -e "${OUT}" | grep -i xxx)
	if (( $? == 0 )); then
		let 'RET|=8'
		OUTPUT+="### neutron:\n${OUT}\n"
	fi
}

source /root/openrc

check_nova
check_neutron

if (( ${RET} != 0 )); then
	echo -e "${OUTPUT}"
fi
exit "${RET}"
