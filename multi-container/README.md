# ZENBU docker - multi-container 

Simply distributed ZENBU genome browser application running across multiple containers:
- zenbu_db (mysql database )
- zenbu_www (apache-based httpd)
- zenbu_agent (for automated cache building and uploaded data preparation)

Two images will be created : a `mysql` image and a `zenbu_app` image
The `zenbu_app` image is the basis for agents, webservices and running ad-hoc command line tools

ZENBU offers a number of command line tools to manipulate the data.
After successful deployement, run `docker docker run --rm -it zenbu_app` for a list of command line tools

## Initial setup
### docker-compose.yaml
- You will need to minimally edit several environment valirables left blank :
   - SMTP environment valirables: `SMTP_HOST`, `SMTP_USER`.  Note : `SMTP_PASSWORD` is read from a file in /secrets/smtp_password.txt
   - http server's name & alias: `APACHE_SERVERALIAS`, `APACHE_SERVERNAME`
- Several other non-essential environment variables have also been left blank : `APACHE_SERVERADMIN`, `ZENBU_CURATOR_EMAIL`
- We recommend to leave the `MYSQL_PASSWORD` stored in /secret/db_zenbu_password.txt as-is
- Named volumes : volumes where mysql, user, and cache data are stored can be customized to be physiocally associated with host mountpoints

### secrets
- Edit the secret file `smtp_password.txt` containing the password associated with `${SMTP_USER}` 
- Editing the `MYSQL_ROOT_PASSWORD` stored in /secret/db_root_password.txt is optional
- We recommend to leave the `MYSQL_PASSWORD` stored in /secret/db_zenbu_password.txt as-is

## Deployement
`docker-compose up`


## Web site

http://{APACHE_SERVERNAME}/zenbu

