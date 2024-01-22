#!/bin/bash
#
SS_SERVER_URL="ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTppK3Q5YXYya1Npb3BYUERr@52.221.202.234:36000#Singapore"

urlencode() {
	local length="${#1}"
	for ((i = 0; i < length; i++)); do
		local c="${1:i:1}"
		case $c in
		[a-zA-Z0-9.~_-]) printf "$c" ;;
		*) printf '%%%02X' "'$c" ;;
		esac
	done
}

encoded_ss_url=$(urlencode "$SS_SERVER_URL")
printf "<https://sslocal.owenyoung.com?ss=%s>\n" "$encoded_ss_url"
