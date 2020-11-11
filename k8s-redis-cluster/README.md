rm -rf /usr/local/kubernetes/volumes/redis-data
mkdir -p /usr/local/kubernetes/volumes/redis-data/redis-cluster-{1,2,3}
chmod a+rw /usr/local/kubernetes/volumes/



kubectl delete -f redis-pv1.yaml
kubectl delete -f redis-pv2.yaml
kubectl delete -f redis-pv3.yaml
kubectl create -f redis-pv1.yaml
kubectl create -f redis-pv2.yaml
kubectl create -f redis-pv3.yaml
kubectl create -f redis-stafulset-master-deployment.yaml
kubectl create -f redis-stafulset-deployment.yaml
