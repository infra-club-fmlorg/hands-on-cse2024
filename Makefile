# global parameters
MAXUSERS = 36
MAXUSERS = 6

STAGE  = devel
B_CONF = work/docker-compose.${STAGE}.yml
U_CONF = work/user-containers.${STAGE}.yml
_CONF  = -f docker-compose.yml -f ${B_CONF} -f ${U_CONF}

all:
	@ printf "[Usage]\n\n"
	@ printf "\tmake start\trun \"docker compose up -d (detach)\" \n"
	@ printf "\tmake up   \trun \"docker compose up -d (detach)\" \n"
	@ printf "\tmake debug\trun \"docker compose up\" \n"
	@ printf "\tmake devel\trun \"docker compose up\" \n"
	@ printf "\n"
	@ printf "\tmake stop\n"
	@ printf "\tmake down\n"
	@ printf "\n"
	@ printf "\tmake clean\n"
	@ printf "\tmake ps\n"
	@ printf "\tmake ls\n"
	@ printf "\n"

build: configure
	@ docker compose ${_CONF} build

devel: debug
debug: build
	@ docker compose ${_CONF} up

start: up
stop:  down
 
up: build
	@ docker compose ${_CONF} up -d

down:
	@ docker compose ${_CONF} down

configure:
	@ env MAXUSERS=${MAXUSERS} sh utils/nginx-config-setup.sh
	@ env MAXUSERS=${MAXUSERS} sh utils/sshd-config-setup.sh
	@ env MAXUSERS=${MAXUSERS} sh utils/user-pwgen.sh
	@ env MAXUSERS=${MAXUSERS} sh utils/production-yml-setup.sh

clean:
	@ find [^v]* -type f \( -name '*~' -or -name '__scan__*' \) -print -delete
	@ docker system prune -f
	@ docker  image prune -f
	@ docker    rmi `docker image ls | sed -e 1d -e 's/  */ /g' | cut -f 3 -d ' '`

#
# utilities
#
ps:
	@ docker ps

psa: ps-a
ps-a:
	@ docker ps -a

ls:
	@ docker image   ls
	@ printf "\n"
	@ docker network ls
	@ printf "\n"
