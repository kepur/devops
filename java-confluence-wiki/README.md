# 创建jira数据库及用户

CREATE DATABASE jiradb CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
grant all on jiradb.* to 'jirauser'@'%' identified by 'bibi123.com';

# 创建confluence数据库及用户
CREATE DATABASE confdb CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
grant all on confdb.* to 'confuser'@'%' identified by 'bibi123.com';
