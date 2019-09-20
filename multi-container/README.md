# ZENBU docker - multi-container 

Simply distributed ZENBU genome browser application running across multiple containers:
- zenbu_db (mysql database )
- zenbu_www (apache-based httpd)
- zenbu_agent (for automated cache building and uploaded data preparation)

Two images will be created : a `mysql` image and a `zenbu_app` image. 
The `zenbu_app` image is the basis for `zenbu_www_1` and `zenbu_agent_1` containers' agents, webservices and running ad-hoc command line tools.

ZENBU offers a number of command line tools to manipulate the data.
After successful deployement, run `docker run --rm -it zenbu_app` for a list of command line tools.


## Initial setup
### .env
You will likely need to minimally provide several environment variables for certain functionalities (emails sent by zenbu upon account creation/modification, mounting an additional NFS-based datalake (readonly) volume, ...).  
These can be provided at buildtime (-e KEY=VALUE) or via a typical docker-compose `.env` file
   - http server's name & alias: `DOMAIN`.   
Default as `localhost`
   - SMTP environment variables: `SMTP_HOST`, `SMTP_USER`.  
Note : `SMTP_PASSWORD` is read from a file in `/secrets/smtp_password.txt`
   - http server's admin contact and emails sent by zenbu upon account creation/modification : `EMAIL`.  
Default to `admin@localhost`  

These values can be redefined at runtime by editing `/etc/zenbu/zenbu.conf`.  

In addtion, when adding an NFS-based datalake (readonly) volume/mountpoint where  bam, cram, bed, ... data files are readily available, you must specify :
   - the NFS server IP adress : `NFS_DATALAKE_IP`
   - the NFS server device (path) to be mounted : `NFS_DATALAKE_DEVICE`

### secrets
Passwords (for smtp server and mysql db) are stored in secret files mounted at build time
- `/secrets/smtp_password.txt` containing the `SMTP_PASSWORD` associated with `SMTP_USER`. No Default provided 
- `/secret/db_zenbu_password.txt` contains the `MYSQL_PASSWORD` associated with the `MYSQL_USER` zenbu-admin user. Default to `zenbu_admin`

### docker-compose.yml & docker-compose.with_datalake-readonly-nfsvolume.yml
- Basic Named volumes : volumes where mysql, user, and cache data are stored can be customized to correspond to desired specific host's mountpoints
- NFS-based datalake (readonly) volume : you may already have bam, cram, bed, ... data files stored in an NFS-server that you wish zenbu to have access to.  
in which case deploy using both docker-compose.yml and docker-compose.with_datalake-readonly-nfsvolume.yml files and provide its IP and device (path) as an envvar


## Deployement
`docker-compose --file=$PWD/docker-compose.yml --project_name zenbu -d up`  
or `docker-compose --file=$PWD/docker-compose.yml --file=$PWD/docker-compose.with_datalake-readonly-nfsvolume.yml --project_name zenbu -d up` to add an NFS-based datalake (readonly) volume

### Web site
(default) http://localhost/zenbu  
(or http://DOMAIN/zenbu if the `DOMAIN` envvar was provided)

### logs
- agent logs : `docker logs zenbu_agent_1`
- mysql logs : `docker logs zenbu_db_1`
- apache logs : `docker logs zenbu_www_1`


## Using command line tools

**example : gettig your list of collabaroations via `zenbu_upload`**
- login/create a user account from zenbu website (e.g. http://localhost/zenbu/user/
- create a file called `~/.zenbu/id_hmac` containing your user account email and the `hmac` key as a tab delimited key/value pair
- run the `zenbu_app` image as a temprary container to which your `~/.zenbu/id_hmac` credentials and zenbu_agent volumes are mounted :  
`docker run --rm --volume-from zenbu_agent_1 --volume ~/.zenbu/id_hmac:/root/.zenbu/id_hmac -it zenbu_app    zenbu_upload -url http://localhost/zenbu -collabs`


