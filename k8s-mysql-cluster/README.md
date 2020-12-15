kubectl patch pv mysql-pv-volume1 -p '{"metadata":{"finalizers":null}}'
kubectl patch pv mysql-pv-volume2 -p '{"metadata":{"finalizers":null}}'
kubectl patch pv mysql-pv-volume3 -p '{"metadata":{"finalizers":null}}'


kubectl delete -f mysql-stafulset-deployment.yaml
rm -rf /usr/local/kubernetes/volumes/mysql-data/
mkdir -p /usr/local/kubernetes/volumes/mysql-data/mysql{1,2,3}
chmod -R a+rw /usr/local/kubernetes/volumes/mysql-data
chmod -R 777 /usr/local/kubernetes/volumes/mysql-data


kubectl create -f mysql-pv1.yaml
kubectl create -f mysql-pv2.yaml
kubectl create -f mysql-pv3.yaml
kubectl create -f mysql-stafulset-deployment.yaml