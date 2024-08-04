#!/bin/sh
#
# $FML: run-test-docker-pc.sh,v 1.3 2024/07/13 12:30:53 fukachan Exp $
#

# check if the test container is already running
is_found=$( docker ps | rev | awk '{if ($1 == "test"){print $1}}' |rev )

# if not running, run it. do nothing if already runinng.
if [ -z "$is_found" ];then
    echo docker run --rm -d -p 8000:80 -p 8022:22 -v ./work/tmp:/home/admin  --name test debian-pc
         docker run --rm -d -p 8000:80 -p 8022:22 -v ./work/tmp:/home/admin  --name test debian-pc
fi

# login the test container
docker exec -it test /bin/bash

exit 0
