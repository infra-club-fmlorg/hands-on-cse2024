#!/bin/sh

is_found=$(docker volume ls | grep laravel_mariadb_data)

if [ -n "$is_found" ];then
	# ok, our volume "laravel_mariadb_data" exists.
	:
else
	docker exec -it laravel-laravel-1 ./artisan migrate
fi

exit 0



