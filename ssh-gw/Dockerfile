# derived from github.com/testcontainers/sshd-docker

FROM alpine:3.16.0
RUN apk add --no-cache openssh && ssh-keygen -A && echo 'root:root' | chpasswd

# import container specific configurations
COPY files/list.users    /
COPY files/entrypoint.sh /

# ENTRYPOINT [ "/usr/sbin/sshd", "-D", "-d" ]
ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
