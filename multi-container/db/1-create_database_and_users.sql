CREATE DATABASE zenbu_users;

CREATE USER 'zenbu_admin'@'%' IDENTIFIED BY 'zenbu_admin';
GRANT SELECT, CREATE TEMPORARY TABLES, LOCK TABLES, CREATE, ALTER, DELETE, INDEX, INSERT, UPDATE, SHOW DATABASES on *.* to 'zenbu_admin'@"%";

CREATE USER 'read'@'%' IDENTIFIED BY 'read';
 /* DO NOT do give read:read grants to the user database */

FLUSH PRIVILEGES;
