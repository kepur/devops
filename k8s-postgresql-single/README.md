
开始安装
mkdir -p /usr/local/kubernetes/volumes/postgresql-data
chmod -R a+rw /usr/local/kubernetes/volumes/postgresql-data
chmod -R 777 /usr/local/kubernetes/volumes/postgresql-data
cd ~/devops/k8s-postgresql-single
kubectl create -f postgresql-pv.yaml


POD=`kubectl get pods -l app=postgresql | grep Running | grep 1/1 | awk '{print $1}'`
kubectl exec -it $POD bash
psql -U postgres -h 127.0.0.1 -p 5432
CREATE user "confluenceuser" with password 'Aa123..com';
创建数据库
CREATE database "confdb" owner "confluenceuser";
GRANT all privileges on database "confdb" to "confluenceuser";
\q

删除数据库
DROP DATABASE confdb;

如果要单独一个权限以及单独一个表，则：
GRANT SELECT ON TABLE mytable TO testUser;



postgresql-client-service
confluence
postgres
bibi123.com

\encoding
update pg_database set encoding = pg_char_to_encoding('UTF8') where datname = 'your_database';

连接某个数据库
postgres=# \c confdb;
You are now connected to database "confdb" as user "postgres".

查看该库的所有 表
confdb=# \d
                        List of relations
 Schema |            Name            |   Type   |     Owner      
--------+----------------------------+----------+----------------
 public | EVENTS                     | table    | confluenceuser
 public | SECRETS                    | table    | confluenceuser
 public | SNAPSHOTS                  | table    | confluenceuser
 public | attachmentdata             | table    | confluenceuser


查看某表结构
confdb=# \d content
                             Table "public.content"
      Column      |            Type             | Collation | Nullable | Default 
------------------+-----------------------------+-----------+----------+---------
 contentid        | bigint                      |           | not null | 
 hibernateversion | integer                     |           | not null | 0
 contenttype      | character varying(255)      |           | not null | 
 title            | character varying(255)      |           |          | 
 lowertitle       | character varying(255)      |           |          | 
 version          | integer                     |           |          | 
 creator          | character varying(255)      |           |          | 
 creationdate     | timestamp without time zone |           |          | 
 lastmodifier     | character varying(255)      |           |          | 