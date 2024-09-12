FROM debian:12-slim

RUN apt update && apt upgrade -y && apt install openssh-server curl sudo python3 nano vim telnet -y

COPY files/entrypoint.sh /
COPY files/www.py        /home/admin/www.py
COPY files/rc.cse        /
COPY htdocs              /home/admin/htdocs

ENTRYPOINT [ "sh", "/entrypoint.sh" ]
