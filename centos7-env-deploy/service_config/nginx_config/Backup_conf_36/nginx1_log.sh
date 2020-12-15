#!/bin/bash
mv -f /opt/nginx_log/eeb8.com.access.log /opt/nginx_log/access_log/eeb8_access$(date -d "yesterday" +"%Y%m%d").log
mv -f /opt/nginx/logs/error.log /opt/nginx_log/error_log/eeb8_error$(date -d "yesterday" +"%Y%m%d").log
mv -f /opt/nginx_log/websocket.access.log /opt/nginx_log/access_log/websocket_access$(date -d "yesterday" +"%Y%m%d").log
mv -f /opt/nginx_log/websocket.error.log /opt/nginx_log/error_log/websocket_error$(date -d "yesterday" +"%Y%m%d").log
mv -f /opt/nginx_log/undefined_domain/undefined.com.access.log   /opt/nginx_log/undefined_domain/undefined.com.access_log$(date -d "yesterday" +"%Y%m%d").log
mv -f /opt/nginx_log/undefined_domain/undefined.com.error.log   /opt/nginx_log/undefined_domain/undefined.com.error_log$(date -d "yesterday" +"%Y%m%d").log
kill -HUP $(cat /opt/nginx/logs/nginx.pid)


