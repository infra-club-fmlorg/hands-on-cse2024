#!/bin/sh
#
# $FML: entrypoint.sh,v 1.14 2024/08/03 12:53:02 fukachan Exp $
#

#
# (1) create a user "admin" without the password :-)
#     - here, we emulate the AWS debian image (AMI).
#       hence, the default user name is "admin" (UID = 1000).
#       you can do "sudo" with empty password.
#
useradd -m -u 1000 -s /bin/bash admin
sed -i '/admin/s/!//' /etc/shadow

test -d /etc/sudoers.d || mkdir -p /etc/sudoers.d
echo '%admin	ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers.d/admin


#
# (2) hostname, bash prompt
#     - create a "/home/admin/.bashrc" which bash reads in the startup.
#     - disabled the color prompt (FOR MYSELF)
#     - the prompt format PS1 is similar to the debian AMI.
#     - set up the environment variable (envvar) HOSTNAME and XHOSTNAME
#       which inherits the envvar ${HOSTNAME} injected by docker.
#       You can customize ${HOSTNAME} in docker-compose.*.yml files.
#
if [ -n "$HOSTNAME" ];then
    echo "color_prompt=no"              >> /home/admin/.bashrc
    echo "PS1='admin@${HOSTNAME}\$ '"   >> /home/admin/.bashrc
    echo "export XHOSTNAME=${HOSTNAME}" >> /home/admin/.bashrc
    export  HOSTNAME=${HOSTNAME}
    export XHOSTNAME=${HOSTNAME}
fi


#
# (3) send the bash history to the docker daemon
#     - tricky :-)
#     - command line logging in two ways
#         - save_history() runs when bash exits.
#         - input_logging() runs each line input (ENTER is pressed)
#     - save_history() saves the history (CLI logs) to /home/admin/.bash_history
#     - input_logging() is tricky.
#       (1) input_loggnig() saves the log to /tmp/.msgbuf.
#       (2) tail (tail -F ...) command watches /tmp/.msgbuf,
#           so that the appended message is written to /proc/1/fd/1
#           which is STDOUT of the init process (PID = 1).
#       (3) the docker daemon watches each container's PID 1 STDOUT
#           and shows all container's log on the host.
#
if test -f "/etc/bashrc"; then  
    FILE=/etc/bashrc
else 
    FILE=/etc/bash.bashrc
fi

cat << EOF >> $FILE

# Added: bash history logging
export HISTTIMEFORMAT="%FT%T %s --- "
# export PROMPT_COMMAND='echo "\${XHOSTNAME} \$(whoami) \$(history 1) [\$?]" >> /tmp/.msgbuf'

function save_history() {
    SAVED_HISTORY_FILE=~/.history.bash.\${XHOSTNAME}-\$USER.\$(date +%Y%m%d)
    history >> \$SAVED_HISTORY_FILE
    test -d /tmp/.shared/ && cp -p \$SAVED_HISTORY_FILE /tmp/.shared/
    : > ~/.bash_history
}

function input_logging () {
    status=\$?
    date=\$(date +"%FT%T %s")
    printf "%10s %10s %s --- %s [%s]\n" "\${XHOSTNAME}" "\$(whoami)" "\${date}" "\${BASH_COMMAND}" \$status >> /tmp/.msgbuf
}

trap save_history  EXIT HUP INT QUIT ABRT ALRM TERM KILL
trap input_logging DEBUG
EOF

touch     /tmp/.msgbuf
chmod 222 /tmp/.msgbuf
tail -F   /tmp/.msgbuf >> /proc/1/fd/1 &


#
# (4)
#
url="${RC_LOCAL_SCRIPT_URL}"
if [ -n "$url" ];then
    printf "# run the startup script defined by URL: %s\n" "$url"
    printf "# script starts (%s)\n" "`date`"
    /usr/bin/perl -e 'srand(time|$$); sleep(rand($$)/60000); sleep(rand(3));'
    curl -o /rc.local "$url"
    /bin/sh /rc.local
    printf "# script   ends (%s)\n" "`date`"
fi
 
#
# (5) sshd
#     - create a directory "/run/sshd"
#     - enabled no password
#       where "ssh-gw" container authenticates each user,
#       once authenticated,
#       no auth between ssh-gw to debian-pc containers :-)
#
mkdir -p  /run/sshd

sed -i /PermitEmptyPasswords/d       /etc/ssh/sshd_config
printf "PermitEmptyPasswords yes" >> /etc/ssh/sshd_config

exec /usr/sbin/sshd -D
