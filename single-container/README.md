# ZENBU docker - single-container 

## Initial setup
- Build docker image
`docker build -t debian-zenbu:2.11.1 .`

- Prepare data folders in host
```
mkdir users cache mysql 
chmod 777 users cache mysql 
```
- Prepare mysql database folders
```
docker run -t \
    -v `pwd`/mysql:/var/lib/mysql \
    -v `pwd`/users:/var/lib/zenbu/users \
    -v `pwd`/cache:/var/lib/zenbu/cache \
    debian-zenbu:2.11.1   /sbin/init_db.sh
```

## Starting ZENBU
```
docker run -td \
    -v `pwd`/mysql:/var/lib/mysql -v \
    -v `pwd`/users:/var/lib/zenbu/users \
    -v `pwd`/cache:/var/lib/zenbu/cache \
    -p 8082:80 \
    debian-zenbu:2.11.1  /sbin/entrypoint.sh
```

## Web site

http://localhost:8082/zenbu

