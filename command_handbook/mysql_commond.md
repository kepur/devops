alter user 'root'@'localhost' identified by 'WllyXS+GM08)!';
grant all privileges on *.* to root@"%" identified by 'WllyXS+GM08)!';
flush privileges;
WllyXS+GM08)!

CREATE USER 'dog'@'localhost' IDENTIFIED BY '123456';
CREATE USER 'pig'@'192.168.1.101_' IDENDIFIED BY '123456';

CREATE USER 'pig'@'%' IDENTIFIED BY '';
CREATE USER 'pig'@'%';


CREATE USER 'apollo'@'%' IDENTIFIED BY 'bibi123.com';
grant all on ApolloConfigDB.* to 'apollo'@'%' identified by 'bibi123.com';
grant all on ApolloPortalDB.* to 'apollo'@'%' identified by 'bibi123.com';
flush privileges;


CREATE USER 'pyproject'@'%' IDENTIFIED BY 'bibi456.com';
grant all on flask-news.* to 'pyproject'@'%' identified by 'bibi456.com';
grant all on flaskmove.* to 'pyproject'@'%' identified by 'bibi456.com';
grant all on flaskmove.* to 'pyproject'@'%' identified by 'bibi456.com';
grant all on django-blog.* to 'pyproject'@'%' identified by 'bibi456.com';
grant all on django-bigdata.* to 'pyproject'@'%' identified by 'bibi456.com';
flush privileges;



GRANT ALL PRIVILEGES ON *.* TO 'cdstm-wechat'@'%' IDENTIFIED BY 'lyf@mwc%2015' WITH GRANT OPTION; (允许所有客户端访问数据库)


UPDATE user SET Password = password ( 'cdstm@kjg2010' ) WHERE User = 'root' ; 


mysqladmin -u root password "cdstm@kjg2010"

SET PASSWORD FOR 'root'@'localhost' = PASSWORD('cdstm@kjg2010');