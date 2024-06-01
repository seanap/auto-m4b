#!/bin/bash
#cd /temp/mp3merge
#file="/temp/mp3merge/auto-m4b-tool.sh"
#cp -u /auto-m4b-tool.sh /temp/mp3merge/auto-m4b-tool.sh

user_name="autom4b"
user_id="1001"
group_id="100"

# Create user if they don't exist
if ! id -u "${PUID}" &>/dev/null; then
    # If PUID is a number, create a user with that id
    if [[ "${PUID}" =~ ^[0-9]+$ ]]; then
        user_id="${PUID}"
    # otherwise create a user with the name from PUID
    else
        user_name="${PUID}"
    fi
    # If PGID is a number, create a user with that id
    if [[ "${PGID}" =~ ^[0-9]+$ ]]; then
        group_id="${PGID}"
    fi

    addgroup --gid "${group_id}" "${user_name}"

    adduser \
        --uid "${user_id}" \
        "${user_name}" \
        --gid "${group_id}"
    echo ""    
    echo "Created missing ${user_name} user with UID ${user_id} and GID ${group_id}"
fi

cmd_prefix=""
if [[ -n "${PUID:-}" ]]; then
    cmd_prefix="/sbin/setuser ${user_name}"
fi

${cmd_prefix} /auto-m4b-tool.sh 2> /config/auto-m4b-tool.log
