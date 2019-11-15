#!/bin/bash

echo "Running init scripts stored in /freeside-init.d"
#
# Run any other init scripts
for f in /entrypoint-init.d/*; do
    case "$f" in
    	*.sh)
			if [ -x "$f" ]; then
			echo "$0: running bash script: $f"
			"$f"
			else
			echo "$0: sourcing bash script: $f"
			. "$f"
			fi
			;;
    	*.pl)
			if [ -x "$f" ]; then
			echo "$0: running perl script: $f"
			"$f"
			else
			echo "$0: sourcing perl script: $f"
			perl "$f"
			fi
			;;
		*)        echo "$0: ignoring $f" ;;
		esac
		echo
done

# If we actually get here, it's because there was no 99_start.sh in the above
# list of scripts
echo "Shutting down in 10 secs!"
sleep 10
