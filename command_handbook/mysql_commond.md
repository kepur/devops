alter user 'root'@'localhost' identified by 'WllyXS+GM08)!';
grant all privileges on *.* to root@"%" identified by 'WllyXS+GM08)!';
flush privileges;
WllyXS+GM08)!


GRANT ALL PRIVILEGES ON *.* TO 'cdstm-wechat'@'%' IDENTIFIED BY 'lyf@mwc%2015' WITH GRANT OPTION; (允许所有客户端访问数据库)


UPDATE user SET Password = password ( 'cdstm@kjg2010' ) WHERE User = 'root' ; 


mysqladmin -u root password "cdstm@kjg2010"

SET PASSWORD FOR 'root'@'localhost' = PASSWORD('cdstm@kjg2010');