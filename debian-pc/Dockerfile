FROM debian:12-slim

RUN apt update && apt upgrade -y && apt install openssh-server curl sudo python3 nano vim telnet -y

COPY files/entrypoint.sh /

ENTRYPOINT [ "sh", "/entrypoint.sh" ]
