# ZENBU docker - multi-container 

Simply distributed ZENBU genome browser application running across multiple containers:
- zenbu_db (mysql database )
- zenbu_www (apache-based httpd)
- zenbu_agent (for automated cache building and uploaded data preparation)

Two images will be created : a `mysql` image and a `zenbu_app` image. 
The `zenbu_app` image is the basis for agents, webservices and running ad-hoc command line tools.

ZENBU offers a number of command line tools to manipulate the data.
After successful deployement, run `docker docker run --rm -it zenbu_app` for a list of command line tools.

## Initial setup
### docker-compose.yaml
- You will need to minimally edit several environment variables left blank :
   - SMTP environment variables: `SMTP_HOST`, `SMTP_USER`.  Note : `SMTP_PASSWORD` is read from a file in /secrets/smtp_password.txt
   - http server's name & alias: `APACHE_SERVERALIAS`, `APACHE_SERVERNAME`
- Several other non-essential environment variables have also been left blank : `APACHE_SERVERADMIN`, `ZENBU_CURATOR_EMAIL`
- We recommend to leave the `MYSQL_PASSWORD` stored in /secret/db_zenbu_password.txt as-is
- Named volumes : volumes where mysql, user, and cache data are stored can be customized to correspond to be actual host's mountpoints

### secrets
- Edit the secret file `smtp_password.txt` containing the password associated with `${SMTP_USER}` 
- Editing the `MYSQL_ROOT_PASSWORD` stored in /secret/db_root_password.txt is optional
- We recommend to leave the `MYSQL_PASSWORD` stored in /secret/db_zenbu_password.txt as-is

## Deployement
`docker-compose up -d`

### Web site
http://localhost/zenbu

### logs
- agent logs : `docker logs zenbu_agent_1`
- mysql logs : `docker logs zenbu_db_1`
- apache logs : `docker logs zenbu_www_1`

## Using command line tools

**example : gettig your list of collabaroations via `zenbu_upload`**
- login/create a user account from http://localhost/zenbu/user/ 
- create a file called `~/.zenbu/id_hmac` containing your user account email and the `hmac` key as a tab delimited key/value pair
- run the `zenbu_app` image as a temprary container mounting your `~/.zenbu/id_hmac` credentials  
`docker docker run --rm -v ~/.zenbu/id_hmac:/root/.zenbu/id_hmac -it zenbu_app zenbu_upload -url http://localhost/zenbu -collabs`


