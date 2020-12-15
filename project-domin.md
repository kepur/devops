| module-name | prot |  domain-name |
| ---- | ---- | ---- | ---- |

flask-news-office        7783             http://smokitoba.com
flask-blogdemo-web       7790             http://cornwalldev.com
flask-nowstragram-web    7781             http://saraluce.com
flask-sportdata-office   7789             http://frutrops.com
flask-pronsearch-web     7788             https://ezzysleep.com
flask-bigdata-office     7792             http://yazddakal.com
php-payment-office       9000             http://questtrde.com


mkdir sportdata && cd sportdata
git clone https://gitlab.mouthmelt.com/root/flask-sportdata-office.git
cp flask-sportdata-office/Dockerfile .
docker build -t wolihi/flask-sportdata-office:v1.0 .
docker push wolihi/flask-sportdata-office:v1.0
cd ~/devops/flask-sportdata-office/
kubectl create -f flask-sportdata-deployment.yaml
kubectl create -f flask-sportdata-svc.yaml
kubectl create -f flask-sportdata-ingress.yaml
cp /opt/nginx/conf/vhost/smokitoba.conf /opt/nginx/conf/vhost/frutrops.conf
sed -i 's/smokitoba/frutrops/g' /opt/nginx/conf/vhost/frutrops.conf
sed -i '/saraluce.conf/a\    include vhost/frutrops.conf;' /opt/nginx/conf/nginx.conf
kubectl get svc -o wide
vim /opt/nginx/conf/vhost/frutrops.conf
systemctl restart nginx


mkdir bigdata && cd bigdata
git clone https://gitlab.mouthmelt.com/root/flask-bigdata-office.git
cp flask-bigdata-office/Dockerfile .
docker build -t wolihi/flask-bigdata-office:v1.0 .
docker push wolihi/flask-bigdata-office:v1.0
cd ~/devops/flask-bigdata-office/
kubectl create -f flask-bigdata-deployment.yaml
kubectl create -f flask-bigdata-svc.yaml
kubectl create -f flask-bigdata-ingress.yaml
cp /opt/nginx/conf/vhost/smokitoba.conf /opt/nginx/conf/vhost/yazddakal.conf
sed -i 's/smokitoba/yazddakal/g' /opt/nginx/conf/vhost/yazddakal.conf
sed -i '/saraluce.conf/a\    include vhost/yazddakal.conf;' /opt/nginx/conf/nginx.conf
kubectl get svc -o wide
#更改10.108.61.2和端口7792
vim /opt/nginx/conf/vhost/yazddaka.conf
systemctl restart nginx



mkdir pronsearch && cd pronsearch
git clone https://gitlab.mouthmelt.com/root/flask-pronsearch-web.git
cp flask-pronsearch-web/Dockerfile .
docker build -t wolihi/flask-pronsearch-web:v1.0 .
docker push wolihi/flask-pronsearch-web:v1.0
cd ~/devops/flask-pronsearch-web/
kubectl create -f flask-pronsearch-deployment.yaml
kubectl create -f flask-pronsearch-svc.yaml
kubectl create -f flask-pronsearch-ingress.yaml

网赚平台(VUE 练习)
fafa188.com
defa98.com
fafa12.com

视频站

博客站


