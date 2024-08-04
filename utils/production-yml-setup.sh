#!/bin/sh
#
# $FML: production-yml-setup.sh,v 1.8 2024/07/13 11:50:15 fukachan Exp $
#

tmpl=$(mktemp)
trap "rm -v $tmpl" 0 1 3 15

init_dir () {
   test -d   /var/tmp/shared || mkdir -p /var/tmp/shared
   chmod 755 /var/tmp/shared
}

customize_container_yml () {
    cp -pv examples/docker-compose.*.yml ./work/
}

create_user_container_yml () {
    local num=$1
    local src=./work/user-containers.devel.yml
    local dst=./work/user-containers.production.yml

    # prepare the template based on examples/user-containers.devel.yml
    cp -pv examples/user-containers.devel.yml $src
    cp -pv examples/user-containers.devel.yml $tmpl
    sed -i s/user30/userXX/g $tmpl

    # (1) create the yml preamble
    sed -n 1,2p              $tmpl          > $dst 

    # (2) append each user yml to $dst (.yml in production)
    for i in $(seq 1 $num)
    do
	repl=$(printf "user%02d" $i)
	sed -e 1,2d -e "s/userXX/$repl/"      $tmpl >> $dst
    done
}


#
# MAIN
#

num=${MAXUSERS:-30}
init_dir
customize_container_yml
create_user_container_yml $num

exit 0
