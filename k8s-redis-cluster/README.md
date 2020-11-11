mkdir -p /usr/local/kubernetes/volumes/redis-data/redis{1,2,3}
chmod a+rw /usr/local/kubernetes/volumes/

kubectl create -f redis-stafulset-deployment.yaml
